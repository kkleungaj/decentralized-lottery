// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedLottery {
    address public owner;
    uint256 public ticketPrice = 0.001 ether; // Ticket price set to 0.001 ETH
    address[] public participants; // Array to store participant addresses
    bool public lotteryOpen = true; // Flag to control lottery state

    // Events to log ticket purchases and winner selection
    event TicketBought(address indexed buyer, uint256 numberOfTickets);
    event WinnerSelected(address indexed winner, uint256 prize);

    constructor() {
        owner = msg.sender; // Set the deployer as the owner
    }

    // Function to buy tickets
    function buyTickets(uint256 numberOfTickets) public payable {
        require(lotteryOpen, "Lottery is closed");
        require(msg.value == numberOfTickets * ticketPrice, "Incorrect Ether amount");
        for (uint256 i = 0; i < numberOfTickets; i++) {
            participants.push(msg.sender); // Add sender to participants for each ticket
        }
        emit TicketBought(msg.sender, numberOfTickets);
    }

    // Function to pick a winner (only callable by owner)
    function pickWinner() public {
        require(msg.sender == owner, "Only owner can pick winner");
        require(participants.length > 0, "No participants");
        require(lotteryOpen, "Lottery is closed");

        // Simple pseudo-random number generator (not secure for mainnet)
        uint256 index = uint256(keccak256(abi.encodePacked(block.timestamp, block.number, owner))) % participants.length;
        address winner = participants[index];

        uint256 pot = address(this).balance;
        uint256 fee = pot / 100; // 1% fee to owner
        uint256 prize = pot - fee; // 99% of pot to winner

        payable(winner).transfer(prize); // Transfer prize to winner
        payable(owner).transfer(fee); // Transfer fee to owner

        emit WinnerSelected(winner, prize);

        // Reset lottery for next round
        delete participants;
        lotteryOpen = true;
    }

    // View function to get current pot size
    function getPotSize() public view returns (uint256) {
        return address(this).balance;
    }

    // View function to get number of tickets sold
    function getNumberOfTickets() public view returns (uint256) {
        return participants.length;
    }
}