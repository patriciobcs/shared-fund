// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./chainlinkInterface.sol";

contract PriceConsumerV3 {
    AggregatorV3Interface internal BTCpriceFeed;
    AggregatorV3Interface internal ETHpriceFeed;
    AggregatorV3Interface internal LinkpriceFeed;

    /**
     * Network: Goerli Testnet
     * BTC/USD Address: 0xA39434A63A52E749F02807ae27335515BA4b07F7
     * ETH/USD Address: 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
     * LINK/USD Address:0x48731cF7e84dc94C5f84577882c14Be11a5B7456
     */
    constructor() {
        BTCpriceFeed = AggregatorV3Interface(
            0xA39434A63A52E749F02807ae27335515BA4b07F7
        );
        ETHpriceFeed = AggregatorV3Interface(
            0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        );
        LinkpriceFeed = AggregatorV3Interface(
            0x48731cF7e84dc94C5f84577882c14Be11a5B7456
        );
    }

    /**
     * Returns the latest prices
     */
    function LatestBTCprice() public view returns (uint80, int256) {
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = BTCpriceFeed.latestRoundData();
        return (roundID, price);
    }

    function LatestETHprice() public view returns (uint80, int256) {
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = ETHpriceFeed.latestRoundData();
        return (roundID, price);
    }

    function LatestLinkprice() public view returns (uint80, int256) {
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = LinkpriceFeed.latestRoundData();
        return (roundID, price);
    }

    /**
     * roundId is NOT incremental. A random number is not guaranteed to be a valid round ID.
     * You must know a valid roundId before consuming historical data.
     *
     * Two valid Round values:        18446744073709554683, 18446744073709555477
     */
    function ETHHistoricalPrice(uint80 roundId) public view returns (int256) {
        (
            uint80 id,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = ETHpriceFeed.getRoundData(roundId);
        require(timeStamp > 0, "Round not complete");
        return price;
    }
}
