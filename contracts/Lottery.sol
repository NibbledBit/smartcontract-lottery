// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is Ownable {
    address payable[] public players;
    uint256 public gbpEntryFee;
    AggregatorV3Interface internal ethUsdPriceFeed;
    AggregatorV3Interface internal gbpUsdPriceFeed;

    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }
    LOTTERY_STATE public lottery_state;

    constructor(address ethUsdPriceFeedAddress, address gbpUsdPriceFeedAddress)
    {
        gbpEntryFee = 5;
        ethUsdPriceFeed = AggregatorV3Interface(ethUsdPriceFeedAddress);
        gbpUsdPriceFeed = AggregatorV3Interface(gbpUsdPriceFeedAddress);
        lottery_state = LOTTERY_STATE.CLOSED;
    }

    function enter() public payable {
        require(lottery_state == LOTTERY_STATE.OPEN, "Lottery is not open!");
        require(msg.value >= getEntranceFee(), "Not enough ETH!");
        players.push(payable(msg.sender));
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

    function startLottery() public onlyOwner {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "Cannot start a new lottery yet!"
        );
        lottery_state = LOTTERY_STATE.OPEN;
    }

    function endLottery() public onlyOwner {
        //pseudo random number
        uint256(
            keccak256(
                abi.encodePacked(
                    nonce,
                    msg.sender,
                    block.difficulty,
                    block.timestamp
                )
            )
        ) % players.length;
    }
}
