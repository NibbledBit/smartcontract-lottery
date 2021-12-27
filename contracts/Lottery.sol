pragma solidity ^0.6.6;

contract Lottery {
    address payable[] public players;

    uint256 public gbpEntryFee;

    constructor() public {
        gbpEntryFee = 5 * (10**18);
    }

    function enter() public {
        //require();
        players.push(msg.sender);
    }

    function getEntranceFee() public view returns (uint256) {}

    function startLotter() public {}

    function endLotter() public {}
}
