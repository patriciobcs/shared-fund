// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./PriceFeedConsumer.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "./SharedFund.sol";
import "uniswap-v3-periphery/libraries/TransferHelper.sol";
import "uniswap-v3-periphery/interfaces/ISwapRouter.sol";
import "aave-v3-core/contracts/protocol/libraries/math/PercentageMath.sol";
import "./interfaces/external/IWETH9.sol";

/**
 * @title The Portfolio contract
 * @notice A contract to manage a portfolio of assets
 */
contract Portfolio is Ownable, SharedFund {
    using PercentageMath for uint256;

    /// @dev An asset in the portfolio represented by its share and flexibility
    struct Asset {
        uint256 proportion;
    }

    /// @dev Wrapped Ether contract/address. Since DEXs don't support native chain tokens
    /// we need to wrap it to ERC20.
    IWETH9 public immutable WETH9;

    /// @dev the base currency of our portfolio. It's the currency we use to buy assets.
    /// and the one we get when we sell assets.
    address portfolioCurrency;

    /// @dev Maps an ERC20 token address its data in the portfolio.
    mapping(address => Asset) public assets; // ERC20 token => balance

    /// @dev List of assets in the portfolio.
    address[] public tokens;

    /// @dev The price feed consumer contract.
    PriceFeedConsumer internal priceFeeds;

    //    /// @dev un-allocated proportion of the portfolio. Meaning that 1-allocatedProportion=remainingProportion
    //    /// and remainingProportion is the proportion of the portfolio that is not allocated to any asset, meaning that
    //    /// it's invested in the base currency (WETH)
    //    uint256 public remainingProportion;

    /// @dev The Uniswap V3 router contract.
    ISwapRouter public immutable swapRouter;

    /// @dev The Uniswap V3 pool fee.
    uint24 public constant poolFee = 3000;

    /// @dev A buy order consists of a token address and an amount to buy.
    struct BuyOrder {
        address token;
        uint256 amount;
        uint256 price;
    }

    event Buy(address token, uint256 amount, uint256 minOut);
    event Sell(address token, uint256 amount, uint256 minOut);
    event AssetState(address token, uint256 balance, uint256 value, uint256 required_value, uint256 proportion);
    event AssetRemoved(address token);
    event log_uint(uint256 value);

    /* ---------------------------- CONSTRUCTOR ---------------------------- */

    /// @dev The constructor
    /// @param _weth The address of the WETH contract
    /// @param _swapRouter The address of the Uniswap V3 router
    /// @param _priceFeed The address of the price feed contract for the base currency (WETH)
    constructor(address _weth, address _swapRouter, address _priceFeed) {
        WETH9 = IWETH9(_weth);
        swapRouter = ISwapRouter(_swapRouter);
        portfolioCurrency = _weth;

        // Add the price feed for the portfolio base currency, WETH.
        priceFeeds = new PriceFeedConsumer(_weth, _priceFeed);
        assets[_weth].proportion = 10_000;
        // 100% expressed in bps
        tokens.push(_weth);
    }

    /// @dev Receive function to allow the contract to receive ETH.
    ///      This is needed to allow the contract to receive ETH from the WETH contract.
    ///      Users should never send ETH directly to the contract, but rather use the deposit function.
    receive() external payable {
        assert(msg.sender == address(WETH9));
        // only accept ETH via fallback from the WETH contract
    }

    /* ------------------------------ MODIFIERS ---------------------------- */

    /// @dev Reverts the transaction if the caller is not the token owner
    /// @param _nftId The NFT Id
    modifier onlyTokenOwner(uint256 _nftId) {
        require(ownerOf(_nftId) == msg.sender, "CALLER_NOT_OWNER");
        _;
    }

    /// @dev Reverts if the asset is not in the portfolio.
    /// @param _token The address of the token to check.
    modifier assetExists(address _token) {
        require(assets[_token].proportion > 0, "Asset does not exist in the portfolio.");
        _;
    }

    /// @dev Reverts if the asset is already in the portfolio.
    /// @param _token The address of the token to check.
    modifier assetDoesNotExist(address _token) {
        require(assets[_token].proportion == 0, "Asset already exists in the portfolio.");
        _;
    }

    /* -------------------------- OWNER FUNCTIONS -------------------------- */

    /// @notice Adds a new asset to the portfolio. When adding an asset, the owner specifies the share of the fund
    ///         the asset must represent, but the actual balance is 0. The balance is updated when the asset
    ///         is bought through rebalancing.
    /// @dev The asset must not already be in the portfolio.
    ///      When an asset is added, a rebalance must be called to re-calculate the proportions of the assets.
    ///      And buy the asset from DEXs.
    /// @param _token The address of the token to add.
    /// @param _proportion The proportion of the portfolio to allocate to the new asset.
    /// @param _priceFeed The address of the price feed contract for the asset.
    function addAsset(address _token, uint256 _proportion, address _priceFeed)
        public
        onlyOwner
        assetDoesNotExist(_token)
    {
        require(_proportion < getRemainingProportion(), "REMAINING_PROPORTION_TOO_LOW");

        uint256 remainingProportion = getRemainingProportion();
        setRemainingProportion(remainingProportion - _proportion);
        priceFeeds.addPriceFeed(_token, _priceFeed);
        assets[_token].proportion = _proportion;
        tokens.push(_token);
    }

    /// @notice modifies the proportion of an asset in the portfolio.
    /// @dev The asset must already be in the portfolio. Only the fund owner can call this function.
    ///      The proportion of the base currency can only be modified by changing the allocations of the other currencies.
    /// @param _token The address of the token to modify.
    /// @param _proportion The new proportion of the portfolio to allocate to the asset, expressed in PERCENTAGE_FACTOR.
    function changeAssetProportion(address _token, uint256 _proportion) public onlyOwner assetExists(_token) {
        require(_token != address(WETH9), "Cannot change the proportion of the base currency");

        uint256 oldProportion = assets[_token].proportion;
        uint256 remainingProportion = getRemainingProportion();
        assets[_token].proportion = _proportion;
        if (_proportion > oldProportion) {
            remainingProportion = remainingProportion - (_proportion - oldProportion);
            setRemainingProportion(remainingProportion);
        } else {
            remainingProportion = remainingProportion + (oldProportion - _proportion);
            setRemainingProportion(remainingProportion);
        }

        // If the proportion is 0, remove the asset from the portfolio
        if (_proportion == 0) {
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

    /* ------------------------------- VIEWS ------------------------------- */

    /// @notice Returns the total value of the portfolio in USD.
    /// @dev The value is calculated by summing the value of each asset in the portfolio.
    ///      To get the value of each asset, we need the ERC20 balance of the fund contract and the priceFeed.
    /// @return portfolio value
    function getPortfolioValue() public view returns (uint256) {
        uint256 portfolioValue = 0;
        for (uint256 i = 0; i < tokens.length; i++) {
            uint256 ERC20Balance = IERC20(tokens[i]).balanceOf(address(this));
            // Get the asset price, multiply by the balance, and add to the portfolio value
            portfolioValue += uint256(priceFeeds.getLatestPrice(tokens[i])) * ERC20Balance;
        }
        return portfolioValue;
    }

    /// @notice Returns the USD value of the fund for a specific asset.
    /// @dev The value is calculated by multiplying the ERC20.balanceOf(this) by the priceFeed.
    /// @param _token The address of the token to get the fund value of.
    /// @return USD value of the fund for a specific asset.
    function getAssetValue(address _token) public view assetExists(_token) returns (uint256) {
        uint256 ERC20Balance = IERC20(_token).balanceOf(address(this));
        return uint256(priceFeeds.getLatestPrice(_token)) * ERC20Balance;
    }

    /// @notice Returns the portfolio share of a specific token.
    /// @dev The share returned is the target share, not the actual share.
    ///      The actual share share is calculated by dividing the token USD value by the funds total value.
    /// @param _token The address of the ERC20 token to get the share of.
    /// @return The theoretical share of the portfolio for the token.
    function getAssetProportion(address _token) public view assetExists(_token) returns (uint256) {
        return assets[_token].proportion;
    }

    /// @notice Returns the unallocated proportion of the portfolio that sits in WETH.
    function getRemainingProportion() public view returns (uint256) {
        return getAssetProportion(address(WETH9));
    }

    /* -------------------------- USERS FUNCTIONS -------------------------- */

    /// @notice Deposit function called by users that will deposit funds for a portfolio share.
    ///         This rebalances the amount of shares each owner has.
    /// @dev This function is payable and will receive ETH from the user. The function will wrap the ether sent by the user into WETH.
    /// @param _nftId The ID of the token to deposit funds for.
    function deposit(uint256 _nftId) external payable onlyTokenOwner(_nftId) {
        uint256 previousValue = getPortfolioValue();

        // register the deposited ETH in the balances
        uint256 depositedAmount = msg.value;
        // Since UNIv3 is in WETH, we need to convert ETH to WETH
        WETH9.deposit{value: msg.value}();

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
        shares[_nftId] += depositedShare;
    }

    /// @notice Withdraw funds from a portfolio share. This rebalances the amount of shares each owner has.
    /// @dev the WETH balance of the contract will be unwrapped to ETH and sent to the user.
    /// @param _nftId The ID of the token to withdraw funds from.
    /// @param _amount The percentage of your share to withdraw, expressed in PERCENTAGE_FACTOr. - e.g. for 50%, amount = 0.5*PERCENTAGE_FACTOR(50.00%)
    function withdraw(uint256 _nftId, uint256 _amount) public onlyTokenOwner(_nftId) {
        require(_amount <= PercentageMath.PERCENTAGE_FACTOR, "Amount must range between 0 and 1e4");
        uint256 share = shares[_nftId];
        // TODO once we have swaps enabled, the withdrawn value should be calculated after slippage.

        // USD Values
        uint256 totalValue = getPortfolioValue();
        uint256 shareValue = totalValue.percentMul(share);
        uint256 withdrawnValue = totalValue.percentMul(share).percentMul(_amount);
        require(withdrawnValue <= totalValue, "Withdrawn value must not be greater than total value");
        uint256 newShareValue = shareValue - withdrawnValue;
        uint256 newTotalValue = totalValue - withdrawnValue;

        // rebalance other user shares based on the new total value
        rebalanceShares(totalValue, newTotalValue);

        // rebalance owner share based on withdrawn value
        uint256 newShareRebalanced;
        if (_amount == PercentageMath.PERCENTAGE_FACTOR) {
            newShareRebalanced = 0;
        } else {
            newShareRebalanced = (newShareValue * PercentageMath.PERCENTAGE_FACTOR) / (newTotalValue);
        }
        shares[_nftId] = newShareRebalanced;

        // Convert USD values to ETH amount for withdrawal
        uint256 etherToWithdraw = withdrawnValue / uint256(priceFeeds.getLatestPrice(portfolioCurrency));

        WETH9.withdraw(etherToWithdraw);
        payable(msg.sender).transfer(etherToWithdraw);
    }

    /// @notice Rebalances the portfolio by swapping assets to reach the target proportions.
    /// @dev The rebalance is done by swapping the assets that are above or below the target proportion.
    ///      The rebalance is done in 2 steps:
    ///      1. Sell the assets that are above the target proportion.
    ///      2. Buy the assets that are below the target proportion.
    /// @param buysLength The number of assets to buy.
    function rebalance(uint256 buysLength) public {
        //TODO refactor this function.
        // What we want to do is :
        // - get the total portfolio value
        // - for each token, get the theoritical value of the token in the portfolio
        // - if the current value is lower then the theoritical one, we swap WETH > token
        // - otherwise, we swap ERC20 > token
        // - we do this for each token in the portfolio
        // - The amountOut of the swap should be calculated based on the price sent by the oracle

        // Get the portfolio value
        uint256 portfolioValue = getPortfolioValue();
        uint256 factor = 100;
        uint256 delta = 10;

        BuyOrder[] memory buys = new BuyOrder[](buysLength);
        uint256 buysCounter = 0;
        uint256 margin = 0;

        // Calculate the proportion of each asset and rebalance
        for (uint256 i = 0; i < tokens.length; i++) {
            // We only buy / sell other ERC20s, not WETH
            if (tokens[i] == address(WETH9)) {
                continue;
            }
            uint256 requiredValue = portfolioValue * assets[tokens[i]].proportion / factor;
            uint256 currentPrice = uint256(priceFeeds.getLatestPrice(tokens[i]));
            uint256 currentBalance = IERC20(tokens[i]).balanceOf(address(this));
            uint256 currentValue = currentPrice * currentBalance;
            emit AssetState(tokens[i], currentBalance, currentValue, requiredValue, assets[tokens[i]].proportion);

            // If the current value is equal or close to the required value, no need to rebalance the asset
            // How close the value can be to the required value is defined by the delta variable
            //TODO the delta here is absolute and doesn't take decimals into account. FIXME
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
            emit log_uint(buys[i].amount);
            emit log_uint(margin);
            uint256 diff = buys[i].amount * buys[i].price;
            if (margin < diff) {
                diff = margin;
            } else {
                margin -= diff;
            }
            uint256 amount = diff / buys[i].price;
            emit log_uint(diff);
            emit log_uint(buys[i].price);
            swapAsset(buys[i].token, amount, true, buys[i].price);
        }
    }

    /* ------------------------- PRIVATE FUNCTIONS ------------------------- */

    /// @notice Sets the unallocated proportion of the portfolio that sits in WETH.
    function setRemainingProportion(uint256 _proportion) internal {
        assets[address(WETH9)].proportion = _proportion;
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

    /// @notice Swaps an asset for another asset.
    /// @dev The swap is done on Uniswap.
    ///      We only swap from WETH <> ERC20 for simplicity purposes.
    /// @param _token The address of the token to swap from.
    /// @param _amount The amount to swap.
    /// @param _isBuy Whether we're buying or selling an ERC20 for WETH.
    /// @param _minOut The minimum amount of tokens to receive.
    function swapAsset(address _token, uint256 _amount, bool _isBuy, uint256 _minOut) internal {
        // If buy is true, then

        if (_isBuy) {
            //FIXME this is wrong since we're not decrementing the balance of the asset we're selling
            swapTokens(portfolioCurrency, _token, _amount, _minOut);
            emit Buy(_token, _amount, _minOut);
        } else {
            //FIXME this is also wrong
            swapTokens(_token, portfolioCurrency, _amount, _minOut);
            emit Sell(_token, _amount, _minOut);
        }
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
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: minOut,
            sqrtPriceLimitX96: 0
        });

        amountOut = swapRouter.exactInputSingle(params);
    }
}
