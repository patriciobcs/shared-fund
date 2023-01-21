// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./PriceFeedConsumer.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "./SharedFund.sol";
import "uniswap-v3-periphery/libraries/TransferHelper.sol";
import "uniswap-v3-periphery/interfaces/ISwapRouter.sol";
import "aave-v3-core/contracts/protocol/libraries/math/PercentageMath.sol";
import "./interfaces/external/IWETH.sol";

/**
 * @title The Portfolio contract
 * @notice A contract to manage a portfolio of assets
 */
contract Portfolio is Ownable, SharedFund {
    using PercentageMath for uint256;

    struct Asset {
        uint256 balance;
        uint256 proportion;
        bool isFlexible;
    }

    /// @dev Wrapped Ether contract/address. Since DEXs don't support native chain tokens
    /// we need to wrap it to ERC20.
    IWETH public immutable weth;

    /// @dev the base currency of our portfolio. It's the currency we use to buy assets.
    /// and the one we get when we sell assets.
    address portfolioCurrency;

    /// @dev Maps an ERC20 token address its data in the portfolio.
    mapping(address => Asset) public assets; // ERC20 token => balance

    /// @dev List of assets in the portfolio.
    address[] public tokens;
    PriceFeedConsumer internal priceFeeds; // price feed consumer (chainlink)
    uint256 public flexibleProportion; // total amount of proportion that are static

    ISwapRouter public immutable swapRouter;
    uint24 public constant poolFee = 3000;

    struct BuyOrder {
        address token;
        uint256 amount;
        uint256 price;
    }

    event Buy(address token, uint256 amount, uint256 price, uint256 change);
    event Sell(address token, uint256 amount, uint256 price, uint256 change);
    event AssetState(address token, uint256 balance, uint256 value, uint256 required_value, uint256 proportion);
    event AssetRemoved(address token);

    constructor(address _weth, address _swapRouter, bool _isFlexible, address _priceFeed) {
        weth = IWETH(_weth);
        swapRouter = ISwapRouter(_swapRouter);
        portfolioCurrency = _weth;

        // Add the price feed for the portfolio base currency, WETH.
        priceFeeds = new PriceFeedConsumer(_weth, _priceFeed);
        assets[_weth].proportion = 100;
        assets[_weth].isFlexible = _isFlexible;
        tokens.push(_weth);

        if (_isFlexible) {
            flexibleProportion = 100;
        }
    }

    receive() external payable {
        assert(msg.sender == address(weth)); // only accept ETH via fallback from the WETH contract
    }

    /**
     * @notice Deposit function called by users that will deposit funds for a portfolio share.
     * This rebalances the amount of shares each owner has.
     * @dev This function is payable and will receive ETH from the user. The function will wrap the ether sent by the user into WETH.
     * @param tokenId The ID of the token to deposit funds for.
     */
    function deposit(uint256 tokenId) external payable {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this share");
        uint256 previousValue = getPortfolioValue();

        // register the deposited ETH in the balances
        uint256 depositedAmount = msg.value;
        // Since UNIv3 is in WETH, we need to convert ETH to WETH
        weth.deposit{value: msg.value}();

        assets[portfolioCurrency].balance += depositedAmount;
        uint256 newValue = getPortfolioValue();

        // update the shares by 1. rebalancing all shares and 2. overriding the current share with the new value
        uint256 depositedValue = depositedAmount * uint256(priceFeeds.getLatestPrice(portfolioCurrency));
        uint256 depositedShare;
        if (previousValue == 0) {
            depositedShare = PercentageMath.PERCENTAGE_FACTOR;
            // 100% of the portfolio
        } else {
            depositedShare = (depositedValue * PercentageMath.PERCENTAGE_FACTOR) / newValue;
        }
        rebalanceShares(previousValue, newValue);
        // update share of the token
        shares[tokenId] += depositedShare;
    }

    /**
     * @notice Rebalances the amount of shares each owner has on a deposit/withdraw event.
     * @param oldValue Old total portfolio value.
     * @param newValue New total portfolio value.
     */
    function rebalanceShares(uint256 oldValue, uint256 newValue) internal {
        // early return if the portfolio was not initialized before as no rebalancing is required.
        // or if the new value is null (if everything was withdrawn).
        if (oldValue == 0 || newValue == 0) {
            return;
        }
        for (uint256 i = 1; i <= totalSupply(); i++) {
            uint256 tokenId = i;
            uint256 share = shares[tokenId];
            uint256 newShare = oldValue * share / (newValue);
            shares[tokenId] = newShare;
        }
    }

    /**
     * @notice Withdraw funds from a portfolio share. This rebalances the amount of shares each owner has.
     * @dev the WETH balance of the contract will be unwrapped to ETH and sent to the user.
     * @param tokenId The ID of the token to withdraw funds from.
     * @param amount The percentage of your share to withdraw, expressed in PERCENTAGE_FACTOr. - e.g. for 50%, amount = 0.5*PERCENTAGE_FACTOR(50.00%)
     *
     */
    function withdraw(uint256 tokenId, uint256 amount) public {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this share");
        require(amount <= PercentageMath.PERCENTAGE_FACTOR, "Amount must range between 0 and 1e4");
        uint256 share = shares[tokenId];
        // TODO once we have swaps enabled, the withdrawn value should be calculated after slippage.

        // USD Values
        uint256 totalValue = getPortfolioValue();
        uint256 shareValue = totalValue.percentMul(share);
        uint256 withdrawnValue = totalValue.percentMul(share).percentMul(amount);
        require(withdrawnValue <= totalValue, "Withdrawn value must not be greater than total value");
        uint256 newShareValue = shareValue - withdrawnValue;
        uint256 newTotalValue = totalValue - withdrawnValue;

        // rebalance other user shares based on the new total value
        rebalanceShares(totalValue, newTotalValue);

        // rebalance owner share based on withdrawn value
        uint256 newShareRebalanced;
        if (amount == PercentageMath.PERCENTAGE_FACTOR) {
            newShareRebalanced = 0;
        } else {
            newShareRebalanced = (newShareValue * PercentageMath.PERCENTAGE_FACTOR) / (newTotalValue);
        }
        shares[tokenId] = newShareRebalanced;

        // Convert USD values to ETH amount for withdrawal
        uint256 etherToWithdraw = withdrawnValue / uint256(priceFeeds.getLatestPrice(portfolioCurrency));
        assets[portfolioCurrency].balance -= etherToWithdraw;

        weth.withdraw(etherToWithdraw);
        payable(msg.sender).transfer(etherToWithdraw);
    }

    /**
     * @notice Adds a new asset to the portfolio
     */
    function addAsset(address _token, uint256 _proportion, bool _isFlexible, address _priceFeed)
        public
        onlyOwner
        assetDoesNotExist(_token)
    {
        require(_proportion < flexibleProportion, "Not sufficient proportion available.");

        uint256 rest = flexibleProportion - _proportion;

        for (uint256 i = 0; i < tokens.length; i++) {
            if (assets[tokens[i]].isFlexible) {
                assets[tokens[i]].proportion = assets[tokens[i]].proportion * rest / flexibleProportion;
            }
        }

        if (!_isFlexible) flexibleProportion = rest;

        priceFeeds.addPriceFeed(_token, _priceFeed);
        assets[_token].proportion = _proportion;
        assets[_token].isFlexible = _isFlexible;
        tokens.push(_token);
    }

    /**
     * @notice Change asset balance to the portfolio
     */
    function changeAssetBalance(address _token, uint256 _change, bool _isAddition)
        public
        onlyOwner
        assetExists(_token)
    {
        // if addition is true, add the change to the balance
        if (_isAddition) {
            assets[_token].balance += _change;
            // if the change is less than the balance, substract the change from the balance
        } else if (assets[_token].balance > _change) {
            assets[_token].balance -= _change;
            // otherwise, set the balance to 0
        } else {
            assets[_token].balance = 0;
        }

        // If the asset balance is 0, remove the asset from the portfolio
        if (assets[_token].balance == 0) {
            // Remove the asset's price feed
            priceFeeds.removePriceFeed(_token);

            // Remove the asset from the assets array
            for (uint256 i = 0; i < tokens.length; i++) {
                if (tokens[i] == _token) {
                    tokens[i] = tokens[tokens.length - 1];
                    tokens.pop();
                    break;
                }
            }
            emit AssetRemoved(_token);
        }
    }

    /**
     * @notice Check if the caller is the owner of the contract
     * @return true if the caller is the owner of the contract
     */
    function isOwner() internal view returns (bool) {
        return owner() == msg.sender;
    }

    /**
     * @notice Returns the portfolio value
     * @return portfolio value
     */
    function getPortfolioValue() public view returns (uint256) {
        uint256 portfolioValue = 0;
        for (uint256 i = 0; i < tokens.length; i++) {
            // Get the asset price, multiply by the balance, and add to the portfolio value
            portfolioValue += uint256(priceFeeds.getLatestPrice(tokens[i])) * assets[tokens[i]].balance;
        }
        return portfolioValue;
    }

    /**
     * @notice Returns the asset value
     * @return asset balance
     */
    function getAssetValue(address _token) public view assetExists(_token) returns (uint256) {
        // Get the asset price, multiply by the balance, and add to the portfolio value
        return uint256(priceFeeds.getLatestPrice(_token)) * assets[_token].balance;
    }

    /**
     * @notice Returns the asset proportion
     * @return asset balance
     *
     */
    function getAssetProportion(address _token) public view assetExists(_token) returns (uint256) {
        return assets[_token].proportion;
    }

    /**
     * @notice Swap an asset for another
     *
     */
    function swapAsset(address _token, uint256 _amount, bool _isBuy, uint256 _price) private {
        // If buy is true, then
        changeAssetBalance(_token, _amount, _isBuy);

        if (_isBuy) {
            //FIXME this is wrong since we're not decrementing the balance of the asset we're selling
            assets[_token].balance += swapTokens(portfolioCurrency, _token, _amount, _price);
            emit Buy(_token, _amount, _price, _amount * _price);
        } else {
            //FIXME this is also wrong
            assets[portfolioCurrency].balance += swapTokens(_token, portfolioCurrency, _amount, _price);
            emit Sell(_token, _amount, _price, _amount * _price);
        }
    }

    /**
     * @notice Rebalance the portfolio
     */
    function rebalance(uint256 buysLength) public {
        // Get the portfolio value
        uint256 portfolioValue = getPortfolioValue();
        uint256 factor = 100;
        uint256 delta = 10;

        BuyOrder[] memory buys = new BuyOrder[](buysLength);
        uint256 buysCounter = 0;
        uint256 margin = 0;

        // Calculate the proportion of each asset and rebalance
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 requiredValue = portfolioValue * assets[tokens[i]].proportion / factor;
            uint256 currentPrice = uint256(priceFeeds.getLatestPrice(tokens[i]));
            uint256 currentBalance = assets[tokens[i]].balance;
            uint256 currentValue = currentPrice * currentBalance;
            emit AssetState(tokens[i], currentBalance, currentValue, requiredValue, assets[tokens[i]].proportion);

            // If the current value is equal or close to the required value, no need to rebalance the asset
            // How close the value can be to the required value is defined by the delta variable
            if (
                currentValue == requiredValue
                    || (currentValue < requiredValue + delta && currentValue > requiredValue - delta)
            ) {
                continue;
            }

            uint256 amount = 0;
            bool isSell = true;

            // Calculate the difference (amount) between the current value and the required value
            if (currentValue > requiredValue) {
                uint256 diff = currentValue - requiredValue;
                amount = diff / currentPrice;
                margin += amount * currentPrice;
            } else if (currentValue < requiredValue) {
                amount = (requiredValue - currentValue) / currentPrice;
                isSell = false;
            }

            if (isSell) {
                swapAsset(tokens[i], amount, false, currentPrice);
            } else {
                // Add the asset to the buys array
                require(buysCounter < buysLength, "The passed buys length is lower than the expected.");
                buys[buysCounter] = BuyOrder(tokens[i], amount, currentPrice);
                buysCounter++;
            }
        }

        require(buysCounter == buysLength, "The passed buys length is higher than the expected.");

        if (buysCounter == 0) return;

        for (uint256 i = 0; i < buysLength; i++) {
            uint256 diff = buys[i].amount * buys[i].price;
            if (margin < diff) {
                diff = margin;
            } else {
                margin -= diff;
            }
            uint256 amount = diff / buys[i].price;
            swapAsset(buys[i].token, amount, true, buys[i].price);
        }
    }

    modifier assetExists(address _token) {
        require(assets[_token].proportion > 0, "Asset does not exist in the portfolio.");
        _;
    }

    modifier assetDoesNotExist(address _token) {
        require(assets[_token].proportion == 0, "Asset already exists in the portfolio.");
        _;
    }

    /**
     * @notice Swap Token through Uniswap
     */
    function swapTokens(address from, address to, uint256 amountIn, uint256 minOut)
        internal
        returns (uint256 amountOut)
    {
        TransferHelper.safeApprove(from, address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: from,
            tokenOut: to,
            fee: poolFee,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: minOut,
            sqrtPriceLimitX96: 0
        });

        amountOut = swapRouter.exactInputSingle(params);
    }
}
