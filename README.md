# Proveably Random Raffle Contracts

## About
Create a proveably random raffle contract using the Foundry framework.
## Learn about：
1. Get Random num from Chainlink VRF
    1.Chainlink-brownie set up
2. Using Chinkink automation to trigger the raffle
    1. Chainlink keeper 

## What to do
1. User can enter by paying for a ticket
    1. Ticket fees are going to go to the winner
2. After X period of time, the winner is chosen randomly
3. Use Chainlink VRF & Chainlink Automation 
    1. Chainlink VRF -> Randomness
    2. Chainlink Automation -> Time base trigger









## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
