// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
        address link;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        } else{
            activeNetworkConfig = getOrCreateAnvilEthConfig();
    }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
        return NetworkConfig({
            entranceFee: 0.1 * 10 ** 18,
            interval: 30,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            gasLane:0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 0,//109256116004356957570131513468047182102347320582950365840134252770217145984213
            callbackGasLimit: 500000,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory){
        if(activeNetworkConfig.vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }
        
        uint96 baseFee = 0.25 ether; // 0.25 LINK
        uint96 gasPrice = 1e9; //1 gwei LINK

        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinatorMock = new VRFCoordinatorV2Mock(
            baseFee,
            gasPrice
        );
        LinkToken link = new LinkToken();
        vm.stopBroadcast();
        return NetworkConfig({
            entranceFee: 0.1 * 10 ** 18,
            interval: 30,
            vrfCoordinator: address(vrfCoordinatorMock),
            gasLane:0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 0, //script will create a subscription
            callbackGasLimit: 500000,
            link: address(link)
        });
    }
}
