// SPDX-License-Identifier: MIT
pragma solidity ^0.8.37;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

contract ChainlinkPriceConsumer {
    AggregatorV3Interface public immutable priceFeed;
    uint256 public constant TIMEOUT = 3 hours;

    event PriceUpdated(int256 price, uint256 updatedAt);

    error InvalidPrice();
    error StalePrice();
    error IncompleteRound();

    constructor(address _priceFeed) {
        require(_priceFeed != address(0), "Invalid feed address");
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function getLatestPrice() public view returns (int256) {
        (
            uint80 roundId,
            int256 price,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();

        if (price <= 0) revert InvalidPrice();
        if (updatedAt == 0 || updatedAt > block.timestamp) revert StalePrice();
        if (block.timestamp - updatedAt > TIMEOUT) revert StalePrice();
        if (answeredInRound < roundId) revert IncompleteRound();

        return price;
    }

    function getDecimals() external view returns (uint8) {
        return priceFeed.decimals();
    }

    function getDescription() external view returns (string memory) {
        return priceFeed.description();
    }
}
