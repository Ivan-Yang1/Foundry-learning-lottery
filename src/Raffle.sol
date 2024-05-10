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

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**
 * @title A sample Raffle contract
 * @dev Implement Chainlink VRFv2
 * @author Ivan-Yang1
 * @notice create a sample raffle contract
 */
contract Raffle is VRFConsumerBaseV2 {
    error Raffle__NotEnoughETHEntered();//Come from which contract__
    error Raffle__TransferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__UpkeepNotNeeded(uint256 currentBalance, uint256 numPlayers, uint256 raffleState);

    /** Type declarations */
    enum RaffleState {
        OPEN,
        CALCULATING
    }
    /** State Variables */
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_entranceFee;//immutable ->save gas
    // @dev Duration of the lottery in seconds
    uint256 private immutable i_interval;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32  private immutable i_gasLane;
    uint64  private immutable i_subscriptionId;
    uint32  private immutable i_callbackGasLimit;

    address payable[] private s_players;
    address private s_recentWinner;
    RaffleState private s_raffleState;

    // @dev Emitted when the raffle is created
    // @param entranceFee The amount of ETH each player must pay to enter the raffle
    // @param interval The interval between each lottery draw
    event RaffleEnter(uint256 indexed requestId, address indexed player);

    // @dev Emitted when the raffle is created
    // @param requestId The ID of the Chainlink VRF request
    uint256 private s_lastTimeStamp;

    constructor(uint256 entranceFee, 
                uint256 interval, 
                address vrfCoordinator,
                bytes32 gasLane,
                uint64 subscriptionId,
                uint32 callbackGasLimit) VRFConsumerBaseV2(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
    }

    /** Events */
    event EnteredRaffle(address indexed player);
    event WinnerPicked(address indexed winner);

    function enterRaffle()  external payable {
        //More gas cost:
        //require(msg.value >= i_entranceFee, "Not enough ETH!");
        if(msg.value < i_entranceFee){
            revert Raffle__NotEnoughETHEntered();
        }
        if(s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }
        s_players.push(payable(msg.sender));

        emit EnteredRaffle(msg.sender);
    }

    // When is the winner supposed to be picked
    /**
     * @dev this is the function that the Chainlink Automation nodes call
     * to see if it's time for perform an upkeep
     * True situations:
     * 1. The time interval has passed between raffle draws.
     * 2. The raffle is open.
     * 3. The contract has EHT (aka, players)
     * 4. The gas lane used for the request has enough LINK.
     */
    function checkUpkeep(bytes memory /* checkData */
    ) public view returns (bool upkeepNeeded, bytes memory /* performData */){
        bool timeHasPassed = (block.timestamp - s_lastTimeStamp) >= i_interval;
        bool isOpen = RaffleState.OPEN == s_raffleState;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = (timeHasPassed && isOpen && hasBalance && hasPlayers);
        return (upkeepNeeded, "0x0");
    }

    function performUpkeep(bytes calldata /* performData */) external {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        }
        s_raffleState = RaffleState.CALCULATING;
        i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
    }

    //CEI: Checks, Effects, Interactions
    function fulfillRandomWords(
        uint256 /* requestId */,
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit WinnerPicked(winner);
        (bool success,) = winner.call{value: address(this).balance}("");
        if(!success) {
            revert Raffle__TransferFailed();
        }
        
        
    }

    /** View / Pure Functions */

    /** Getter Function */

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}


