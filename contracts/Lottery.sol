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
        gbpEntryFee = 5 * (10**18);
        ethUsdPriceFeed = AggregatorV3Interface(ethUsdPriceFeedAddress);
        gbpUsdPriceFeed = AggregatorV3Interface(gbpUsdPriceFeedAddress);
    }

    function enter() public {
        //require();
        players.push(msg.sender);
    }

    /// Don't send this to product because the math isn't safe
    /// TODO:  use Safe math and workout why new versions of
    ///        Solidity don't need safe math?
    function getEntranceFee() public view returns (uint256) {
        (, int256 gbpUsdPrice, , , ) = gbpUsdPriceFeed.latestRoundData();
        (, int256 ethUsdPrice, , , ) = ethUsdPriceFeed.latestRoundData();

        // convert to 18 decimals
        uint256 adjustedEthUsdPrice = uint256(ethUsdPrice) * 10**10;
        uint256 adjustedGbpUsdPrice = uint256(gbpUsdPrice) * 10**10;
        //gbpEntryFee = £5
        // £5 to USD = $6.72
        uint256 usdEntryFee = (gbpEntryFee * 10**18) * adjustedGbpUsdPrice;
        // ETH to USD = $4067
        // $6.72 / $4067
        uint256 costToEnter = usdEntryFree / adjustedEthUsdPrice;
        //0.001652323580034423 * 10 ** 18
        return costToEnter;
    }

    function startLotter() public {}

    function endLotter() public {}
}
