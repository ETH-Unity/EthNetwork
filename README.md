# ETHNetwork: GoQuorum Testnet and Smart Contracts

This repository contains the blockchain infrastructure and smart contracts enabling interactions between users and IoT devices in a multiplayer environment. It serves as a backend for the [ETH-WEB Unity project](https://github.com/ETH-Unity/ETH-WEB).

## Overview

EthNetwork provides:

- Local Quorum blockchain testnet configuration

- Smart contracts for:
    - User-to-User interactions
    - User-to-Device interactions
    - Device-to-Device interactions
    - Document signing and NFT certificate creation

- Deployment instructions and tools

## Prerequisites

- Windows 10/11
- Docker Desktop
- Windows Subsystem for Linux (WSL)
- Node.js v14+
- MetaMask (browser extension)
- Remix IDE

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


## Connecting MetaMask to Quorum

### MetaMask browser extension is required

1. Open MetaMask and click on the network dropdown
2. Select "Add Network" > "Add a network manually"
3. Enter the following details:
- Network Name: `Quorum`
- RPC URL: `http://localhost:8545`
- Chain ID: `1337`
- Currency Symbol: `eth`

### Import test accounts using private keys

1. Add Account in MetaMask through `Import a wallet or account - private key`
2. Get test account private keys from: `quorum-test-network\config\nodes\member\accountPrivateKey`

## Setup

### Remix

#### Deploying Contracts

1. Open [Remix IDE](https://remix.ethereum.org/)
2. Create new files in the contracts folder and copy the contract code from:

-  [`Contracts/UserUser.sol`](https://github.com/ETH-Unity/EthNetwork/blob/main/Contracts/UserUser.sol)
-  [`Contracts/UserDevice.sol`](https://github.com/ETH-Unity/EthNetwork/blob/main/Contracts/UserDevice.sol)
-  [`Contracts/DeviceDevice.sol`](https://github.com/ETH-Unity/EthNetwork/blob/main/Contracts/DeviceDevice.sol)
-  [`Contracts/DocumentSigner.sol`](https://github.com/ETH-Unity/EthNetwork/blob/main/Contracts/DocumentSigner.sol)
-  [`Contracts/CertificateNFT.sol`](https://github.com/ETH-Unity/EthNetwork/blob/main/Contracts/CertificateNFT.sol)

3. Compile the contracts:

- Use the Solidity compiler specified in the contract
- Click "Compile" for each contract

4. Deploy to Quorum:

- In `Deploy & run transactions` select `"ENVIRONMENT"` as `"Injected Provider - MetaMask"`
- Connect with your Quorum-connected MetaMask account
- Select the contract and deploy

#### Key Notes

- It's recommended to deploy all contracts from the same account (e.g., `member 1`) for easier management.
-  `UserDevice` requires a wallet for the door. Do **not** use the deployer account.
-  `DeviceDevice` requires a wallet for the fan. This must also be distinct from the deployer account.
- To compile `CertificateNFT`  
   - In the Solidity Compiler tab, click on "Advanced Configurations" 
   - Under "EVM VERSION", select "istanbul" from the dropdown menu
   - Then compile the contract normally

#### Unity Integration

To connect the Unity environment with the contracts:

1. Copy the deployed contract addresses from Remix
2. In Unity, locate the relevant GameObjects/Prefabs and set the contract addresses in the Inspector to the "Contract Address" fields:

-  **UserUser contract**: Set contract address in `UserUser` (component of `Player Prefab`)
-  **UserDevice contract**: The contract address needs to be assigned for each door in the scene. These can be found under the room prefabs in the scene with names `"Door_Hinge"`. Additionally the address needs to be assigned to `AccessControlManager` (component of `Player Prefab`)
-  **DeviceDevice contract** requires both contract address and private key of the wallet assigned to the device on deployment. This is due to device interactions with the chain happening on server through RPC URL. Both can be assigned in the `Fan` GameObject in the scene hierarchy.
-  **DocumentSigner contract**: Set in `DocumentHashing` (component of `Player Prefab`)
-  **CertificateNFT contract**: Set in `NFTManager` (Child GameObject of `Player Prefab`)

## Contracts

#### UserUser Contract

The `UserUser` smart contract enables transfers between clients in the Unity environment. Instead of direct transfers, funds are held in the contract as pending transfers, which must be explicitly signed by the recipient to complete. Additionally, a message can be sent within the transaction which gets stored in the contract and gets returned to the recipient when signed.

##### UserUser Information Flow
<img  src="https://github.com/ETH-Unity/EthNetwork/blob/main/Diagrams/User-User_UML.png"  height="400">

#### UserDevice Contract

The `UserDevice` smart contract provides an access control system designed to manage permissions for clients interacting with IoT devices. In this implementation, devices are represented as doors. The contract enables an owner and designated admins to assign, modify, or revoke permissions, determining which clients can interact with devices and under what conditions.

##### Table of Access Control Roles

|  **Role**  | Grant/Revoke Basic | Grant/Revoke Admin | Open Door |
|:--:|:--:|:--:|:--:|
| None (0) | ❌ | ❌ | ❌ |
| Default (1) | ❌ | ❌ | ❓ |
| Service (2) | ❌ | ❌ | ✅ |
| Admin (3)| ✅ | ❌ | ✅ |
| Owner (Deployer) | ✅ | ✅ | ✅ |

##### UserDevice Information Flow
<img  src="https://github.com/ETH-Unity/EthNetwork/blob/main/Diagrams/User-Device_UML.png"  height="400">

#### DeviceDevice Contract

The `DeviceDevice` smart contract stores temperature data from a simulated sensor on-chain, creating an immutable and verifiable record. A fan reads this blockchain data to automatically adjust fan speed (100-1000 RPM based on 15-30°C range). 

This showcases how IoT devices can operate autonomously through blockchain, enabling immutable device-to-device communication. All blockchain interactions happen server-side while Unity clients receive real-time visual updates through networking.

##### DeviceDevice Information Flow
<img  src="https://github.com/ETH-Unity/EthNetwork/blob/main/Diagrams/Device-Device_UML.png"  height="400">

#### DocumentSigner Contract

The `DocumentSigner` smart contract allows digital signing of documents by hashing the URL's content using SHA-256. Players can provide a URL in the game through the UI, and the content is hashed client-side and signed through MetaMask transactions. Successful signings are broadcasted to all players via the in-game chat to allow comparison of signature hashes.

**Noteworthy:**
- Content fetching is only possible with URLs that have CORS enabled (e.g., GitHub raw files, public APIs, text files).
- If the content in the URL changes, so will the hash of the signature. 
- A wallet can only sign a document once.

##### DocumentSigner Information Flow
<img  src="https://github.com/ETH-Unity/EthNetwork/blob/main/Diagrams/DocumentSigner_UML.png"  height="400">

#### CertificateNFT Contract

The CertificateNFT smart contract provides NFT-based certificate creation and management. Players can deploy ERC-721 contracts and mint NFT certificates with embedded data to specific recipients. This creates verifiable, immutable certificates stored on the blockchain.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
