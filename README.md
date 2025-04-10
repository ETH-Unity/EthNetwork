# Multiplayer Unity-ETH IoT Interaction Project

This project implements a blockchain-based multiplayer environment using [Go Quorum](https://www.goquorum.com), enabling interactions between users and IoT devices through smart contracts.

## Prerequisites

- Windows 10/11
- Docker Desktop
- Windows Subsystem for Linux (WSL)
- Remix IDE

## Blockchain Setup (Go Quorum Testnet)

### Local Testnet Initialization

- Ensure Docker daemon is running
- Have WSL installed and configured

Install the [quorum-dev-quickstart](https://docs.goquorum.consensys.io/tutorials/quorum-dev-quickstart/using-the-quickstart) testnet with 

```
npx quorum-dev-quickstart
```
Start the blockchain using:
```
./start.sh
```

### Network Configuration

- **Network Type**: Permissioned Ethereum network
- **Consensus Mechanism**: Raft or Istanbul BFT
- **Validators**: Predefined in quickstart

### Accounts

- Member 1
- Member 2
- Member 3

## Smart Contracts

There are three types of smart contracts made with solidity. A user-user, user-device and device-device contracts. 

### EtherTransfer
The user-user smart contract enables direct Ether transfers between users through the blockchain.

#### Key Functions

- `receive()`: Handles incoming Ether transfers
- `sendEther(address to, uint amount)`: Transfers specified amount to recipient
- `getBalance()`: Retrieves current contract balance

## Deployment Process

### Using Remix IDE
- Open Remix IDE
- Create new file and paste the EtherTransfer contract
- Compile the contract with a connected account to the testnet
- From Artifacts folder in the contract.json scroll down and get the data inside
	"abi": [ ... ]

## Unity Integration

- Import contract address and ABI into Unity
