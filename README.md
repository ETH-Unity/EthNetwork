# ETHNetwork: GoQuorum Testnet and Smart Contracts

This repository contains the blockchain infrastructure and smart contracts enabling interactions between users and IoT devices in a multiplayer environment. It serves as the backend for [UnityNethereum](https://github.com/ETH-Unity/UnityNethereum).

---

## Overview

EthNetwork provides:

- Local Quorum blockchain testnet configuration
- Smart contracts for:
  - User-to-User interactions
  - User-to-Device interactions
  - Device-to-Device interactions
- Deployment instructions and tools

---

## Prerequisites

- Windows 10/11
- Docker Desktop
- Windows Subsystem for Linux (WSL)
- Node.js v14+
- MetaMask (browser extension)
- Remix IDE

---

## Quorum Testnet Setup

### Installation

Follow the official [Quorum Developer Quickstart Guide](https://docs.goquorum.consensys.io/tutorials/quorum-dev-quickstart/) to set up a local Quorum testnet.

### Recommended Options

- Ethereum client: `2. GoQuorum`
- Private transactions: `y`
- Blockscout: `y`

### Network Details

Once running, your local Quorum network exposes:
- RPC URL: `http://localhost:8545`
- Network ID: `1337`
- Block Explorer: `http://localhost:25000`
- BlockScout : `http://localhost:26000` (optional)

---
## Connecting MetaMask to Quorum

### MetaMask browser extension is required

1. Open MetaMask and click on the network dropdown
2. Select "Add Network" > "Add a network manually"
3. Enter the following details:
   - Network Name: `Quorum Local`
   - RPC URL: `http://localhost:8545`
   - Chain ID: `1337`
   - Currency Symbol: `ether`

### Import test accounts using private keys

 1. Add Account in MetaMask through `Import a wallet or account - private key`
 2. Get test account private keys from: `quorum-test-network\config\nodes\member\accountPrivateKey``
---
## Setup

### Remix

#### Deploying Contracts

1. Open [Remix IDE](https://remix.ethereum.org/)
2. Create new files in the contracts folder and copy the contract code from:
   - [`Contracts/UserUser.sol`](https://github.com/ETH-Unity/EthNetwork/blob/main/Contracts/UserUser.sol)
   - [`Contracts/UserDevice.sol`](https://github.com/ETH-Unity/EthNetwork/blob/main/Contracts/UserDevice.sol)
   - [`Contracts/DeviceDevice.sol`](https://github.com/ETH-Unity/EthNetwork/blob/main/Contracts/DeviceDevice.sol)

3. Compile the contracts:
   - Use the Solidity compiler specified in the contract
   - Click "Compile" for each contract

4. Deploy to Quorum:
   - In `Deploy & run transactions` select `"ENVIRONMENT"` as `"Injected Provider - MetaMask"`
   - Connect with your Quorum-connected MetaMask account
   - Select the contract and deploy
   

#### Key Notes

- It's recommended to deploy all contracts from the same account (e.g., `member 1`) for easier management.
- `UserDevice` requires a dedicated door account. Do **not** use the deployer account.
- `DeviceDevice` requires separate accounts for the fan and temperature sensor. These must also be distinct from the deployer account.

#### Unity Integration

To connect the Unity environment with the contracts:

1. Copy the deployed contract address from Remix
2. Add the contract addresses to [Assets/Resources/configKeys.json](https://github.com/ETH-Unity/UnityNethereum/blob/master/Assets/Resources/configKeys.json) in Unity:
```json 
{
	"ethereum":  {
		"doorPrivateKey": "Door Account Private Key Here",
		"tempPrivateKey": "Temperature Sensor Private Key Here",
		"contractUserUser": "Use-User contract address here",
		"contractUserDevice": "Use-Device contract address here",
		"contractDeviceDevice": "Device-Device contract address here",
		"rpcUrl":  "http://127.0.0.1:8545"
	},
	"network":  {
	"chainId":  1337,
	"networkName":  "testnet"
	}
}
 ```

- Add the private keys for accounts assigned to the `Door` in `UserDevice` and the `temperature sensor` in `DeviceDevice`

### Contract ABIs
If contracts are modified make sure to obtain the updated ABI file from remix and update the ABI files in Unity
1. In Remix, go to the "Solidity Compiler" tab
2. Compile the given contract
3. Copy the ABI JSON from the popup

---
## Smart Contracts

### Contract Overview

#### UserUser Contract
The `UserUser` smart contract enables transfers between users in the unity environment. Instead of direct transfers, funds are **held in the contract** as **pending transfers**, which must be **explicitly signed** by the recipient to complete. Additionally a message can be sent within the transaction which gets stored in the contract and gets returned to the recipient when signed.

[UML_IMAGE]

#### UserDevice Contract
The `UserDevice` smart contract provides access control system designed to manage access control for users interacting with an IoT device. In this case, the device is represented as a "door," which can be either a physical or digital resource. The contract enables an owner and designated admins to assign, modify, or revoke permissions, determining which users can interact with the device and under what conditions.

##### Table of Access Control Roles
| **Role** | Grant/Revoke Basic | Grant/Revoke Admin | Open Door |
|:--:|:--:|:--:|:--:|
| None (0) | ❌ | ❌ | ❌ |
| Default (1) | ❌ | ❌ | ❓ |
| Admin (2)| ✅ | ❌ | ✅ |
| Owner (Deployer) | ✅ | ✅ | ✅ |

[UML_IMAGE]

#### DeviceDevice Contract
The DeviceDevice smart contract is designed to manage interactions between IoT devices. In this case, it links a sensor and a fan, enabling the sensor to report temperature data to the blockchain.

[UML_IMAGE]
