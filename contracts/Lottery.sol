// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Lottery{
    address payable public admin;
    address[] public players;
    uint256 public totalPrize;
    bool private initialized;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can call this");
        _;
    }

    // Initialize function to replace constructor
    function initialize(address payable _admin) external {
        require(!initialized, "Contract is already initialized");
        admin = _admin;
        initialized = true; // Prevents re-initialization
    }

    function enterLottery(uint256 amount) public payable {
        require(msg.value == amount, "Sent value must match the amount");
        require(amount > 0, "Amount must be greater than 0");
        players.push(msg.sender);
        totalPrize += amount;
    }

    function pickWinner() public onlyAdmin {
        require(players.length > 0, "No players in the lottery");
        
        uint256 winnerIndex = random() % players.length;
        address payable winner = payable(players[winnerIndex]);
        uint256 prize = totalPrize;
        
        // Reset contract state
        totalPrize = 0;
        delete players;
        
        (bool success, ) = winner.call{value: prize}("");
        require(success, "Failed to send Ether");
    }

    function getPrize() public view returns (uint256) {
        return totalPrize;
    }

    function random() private view returns (uint256) {
    return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));
    }
}
//prevrandao