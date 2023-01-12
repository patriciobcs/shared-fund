// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./PriceFeedConsumer.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "./SharedFund.sol";
import "./SwapToken.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "aave-v3-core/contracts/protocol/libraries/math/WadRayMath.sol";
import "aave-v3-core/contracts/protocol/libraries/math/PercentageMath.sol";

/**
 * @title The Portfolio contract
 * @notice A contract to manage a portfolio of assets
 */
contract Portfolio is Ownable, SharedFund {
    using WadRayMath for uint256;
    using PercentageMath for uint256;

    struct Asset {
        uint256 balance;
        uint256 proportion;
        bool isFlexible;
    }

    mapping(string => Asset) public assets; // symbols => balance
    string[] public symbols; // symbols
    PriceFeedConsumer internal priceFeeds; // price feed consumer (chainlink)
    SwapToken internal swap; // swap tokens through uniswap
    string public baseSymbol; // symbol use as a base pair in the swaps
    uint256 public flexibleProportion; // total amount of proportion that are static
    uint256 WAD = WadRayMath.WAD;
    string portfolioCurrency = "ETH";


    struct BuyOrder {
        string symbol;
        uint256 amount;
        uint256 price;
    }

    event Buy(string symbol, uint256 amount, uint256 price, uint256 change);
    event Sell(string symbol, uint256 amount, uint256 price, uint256 change);
    event AssetState(string symbol, uint256 balance, uint256 value, uint256 required_value, uint256 proportion);
    event AssetRemoved(string symbol);

    constructor(string memory _symbol, uint256 _balance, bool _isFlexible, address _priceFeed) {
        // Add first asset to the portfolio
        priceFeeds = new PriceFeedConsumer(_symbol, _priceFeed);
        assets[_symbol].balance = _balance;
        assets[_symbol].proportion = 100;
        assets[_symbol].isFlexible = _isFlexible;
        symbols.push(_symbol);

        swap = new SwapToken(new ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564));

        if (_isFlexible) {
            flexibleProportion = 100;
        }
    }

    /**
     * @notice Deposit funds for a portfolio share. This rebalances the amount of shares each owner has.
     * @param tokenId The ID of the token to deposit funds for.
     */
    function deposit(uint256 tokenId) public payable {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this share");
        uint256 previousValue = getPortfolioValue();

        // register the deposited ETH in the balances
        uint256 depositedAmount = msg.value;
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
        shares[tokenId] += depositedShare;
        // update share of the token
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
        payable(msg.sender).transfer(etherToWithdraw);
    }

    /**
     * @notice Adds a new asset to the portfolio
     */
    function addAsset(
        string memory _symbol,
        uint256 _balance,
        uint256 _proportion,
        bool _isFlexible,
        address _priceFeed
    ) public onlyOwner assetDoesNotExist(_symbol) {
        require(_proportion < flexibleProportion, "Not sufficient proportion available.");

        uint256 rest = flexibleProportion - _proportion;

        for (uint256 i = 0; i < symbols.length; i++) {
            if (assets[symbols[i]].isFlexible) {
                assets[symbols[i]].proportion = assets[symbols[i]].proportion * rest / flexibleProportion;
            }
        }

        if (!_isFlexible) flexibleProportion = rest;

        priceFeeds.addPriceFeed(_symbol, _priceFeed);
        assets[_symbol].balance = _balance;
        assets[_symbol].proportion = _proportion;
        assets[_symbol].isFlexible = _isFlexible;
        symbols.push(_symbol);
    }

    /**
     * @notice Change asset balance to the portfolio
     */
    function changeAssetBalance(string memory _symbol, uint256 _change, bool _isAddition)
        public
        onlyOwner
        assetExists(_symbol)
    {
        // if addition is true, add the change to the balance
        if (_isAddition) {
            assets[_symbol].balance += _change;
            // if the change is less than the balance, substract the change from the balance
        } else if (assets[_symbol].balance > _change) {
            assets[_symbol].balance -= _change;
            // otherwise, set the balance to 0
        } else {
            assets[_symbol].balance = 0;
        }

        // If the asset balance is 0, remove the asset from the portfolio
        if (assets[_symbol].balance == 0) {
            // Remove the asset's price feed
            priceFeeds.removePriceFeed(_symbol);

            // Remove the asset from the assets array
            for (uint256 i = 0; i < symbols.length; i++) {
                if (keccak256(abi.encodePacked(symbols[i])) == keccak256(abi.encodePacked(_symbol))) {
                    symbols[i] = symbols[symbols.length - 1];
                    symbols.pop();
                    break;
                }
            }
            emit AssetRemoved(_symbol);
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
        for (uint256 i = 0; i < symbols.length; i++) {
            // Get the asset price, multiply by the balance, and add to the portfolio value
            portfolioValue += uint256(priceFeeds.getLatestPrice(symbols[i])) * assets[symbols[i]].balance;
        }
        return portfolioValue;
    }

    /**
     * @notice Returns the asset value
     * @return asset balance
     */
    function getAssetValue(string memory _symbol) public view assetExists(_symbol) returns (uint256) {
        // Get the asset price, multiply by the balance, and add to the portfolio value
        return uint256(priceFeeds.getLatestPrice(_symbol)) * assets[_symbol].balance;
    }

    /**
     * @notice Returns the asset proportion
     * @return asset balance
     *
     */
    function getAssetProportion(string memory _symbol) public view assetExists(_symbol) returns (uint256) {
        return assets[_symbol].proportion;
    }

    /**
     * @notice Swap an asset for another
     *
     */
    function swapAsset(string memory _symbol, uint256 _amount, bool _isBuy, uint256 _price) private {
        // If buy is true, then
        changeAssetBalance(_symbol, _amount, _isBuy);

        if (_isBuy) {
            assets[_symbol].balance += swap.swapTokens("ETH",_symbol,_amount,_price);
            emit Buy(_symbol, _amount, _price, _amount * _price);
        } else {
            assets[portfolioCurrency].balance += swap.swapTokens(_symbol,"ETH",_amount,_price);
            emit Sell(_symbol, _amount, _price, _amount * _price);
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
        for (uint256 i = 0; i < symbols.length; i++) {
            uint256 requiredValue = portfolioValue * assets[symbols[i]].proportion / factor;
            uint256 currentPrice = uint256(priceFeeds.getLatestPrice(symbols[i]));
            uint256 currentBalance = assets[symbols[i]].balance;
            uint256 currentValue = currentPrice * currentBalance;
            emit AssetState(symbols[i], currentBalance, currentValue, requiredValue, assets[symbols[i]].proportion);

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
                swapAsset(symbols[i], amount, false, currentPrice);
            } else {
                // Add the asset to the buys array
                require(buysCounter < buysLength, "The passed buys length is lower than the expected.");
                buys[buysCounter] = BuyOrder(symbols[i], amount, currentPrice);
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
            swapAsset(buys[i].symbol, amount, true, buys[i].price);
        }
    }

    modifier assetExists(string memory _symbol) {
        require(assets[_symbol].balance > 0, "Asset does not exist in the portfolio.");
        _;
    }

    modifier assetDoesNotExist(string memory _symbol) {
        require(assets[_symbol].balance == 0, "Asset already exists in the portfolio.");
        _;
    }
}
