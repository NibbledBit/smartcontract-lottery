// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract Lottery {
    address payable[] public players;
    uint256 public gbpEntryFee;
    AggregatorV3Interface internal ethUsdPriceFeed;
    AggregatorV3Interface internal gbpUsdPriceFeed;

    constructor(address ethUsdPriceFeedAddress, address gbpUsdPriceFeedAddress)
        public
    {
        gbpEntryFee = 5;
        ethUsdPriceFeed = AggregatorV3Interface(ethUsdPriceFeedAddress);
        gbpUsdPriceFeed = AggregatorV3Interface(gbpUsdPriceFeedAddress);
    }

    function enter() public {
        //require();
        players.push(msg.sender);
    }

    function getGbpUsdPrice() public view returns (uint256) {
        (, int256 gbpUsdPrice, , , ) = gbpUsdPriceFeed.latestRoundData();
        return uint256(gbpUsdPrice);
    }

    function getEthUsdPrice() public view returns (uint256) {
        (, int256 ethUsdPrice, , , ) = ethUsdPriceFeed.latestRoundData();
        return uint256(ethUsdPrice);
    }

    /// Don't send this to product because the math isn't safe
    /// TODO:  use Safe math and workout why new versions of
    ///        Solidity don't need safe math?
    function getEntranceFee() public view returns (uint256) {
        (, int256 gbpUsdPrice, , , ) = gbpUsdPriceFeed.latestRoundData();
        (, int256 ethUsdPrice, , , ) = ethUsdPriceFeed.latestRoundData();

        // convert to 18 decimals
        uint256 adjustedGbpUsdPrice = uint256(gbpUsdPrice) * 10**10;
        uint256 adjustedEthUsdPrice = uint256(ethUsdPrice);
        //gbpEntryFee = £5
        // £5 to USD = $6.72
        uint256 usdEntryFee = (gbpEntryFee) * adjustedGbpUsdPrice;
        // ETH to USD = $4067
        // $6.72 / $4067
        uint256 costToEnter = usdEntryFee / adjustedEthUsdPrice;
        //0.001652323580034423
        return costToEnter * 10**8;
    }

    function startLotter() public {}

    function endLotter() public {}
}
