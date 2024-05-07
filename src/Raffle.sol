// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title A sample Raffle contract
 * @dev Implement Chainlink VRFv2
 * @author Ivan-Yang1
 * @notice create a sample raffle contract
 */
contract Raffle {
    error Raffle__NotEnoughETHEntered();
    

    uint256 private immutable i_entranceFee;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle()  external payable {
        //More gas cost:
        //require(msg.value >= i_entranceFee, "Not enough ETH!");
        if(msg.value < i_entranceFee){
            revert Raffle__NotEnoughETHEntered();
        }
    }

    function pickWinner() public {}

    /** Getter Function */

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}


