// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract UserUser {
    event TransferInitiated(address indexed sender, address indexed receiver, uint amount, string message);
    event TransferSigned(address indexed receiver, uint amount, string message); // Added message

    struct PendingTransfer {
        address sender;
        uint amount;
        bool signed;
        string message;
    }

    mapping(address => PendingTransfer[]) public pendingTransfers;

    receive() external payable {}

    function initiateTransfer(address payable _to, uint _amount, string memory _message) external payable {
        require(address(this).balance >= _amount, "Insufficient contract balance");
        pendingTransfers[_to].push(PendingTransfer({
            sender: msg.sender,
            amount: _amount,
            signed: false,
            message: _message
        }));
        emit TransferInitiated(msg.sender, _to, _amount, _message);
    }

    function signTransfer() external {
        PendingTransfer[] storage transfers = pendingTransfers[msg.sender];
        require(transfers.length > 0, "No pending transfers");
        for (uint i = 0; i < transfers.length; i++) {
            if (!transfers[i].signed) {
                transfers[i].signed = true;
                uint amount = transfers[i].amount;
                string memory message = transfers[i].message; // Capture message
                (bool success, ) = msg.sender.call{value: amount}("");
                require(success, "Transfer failed");
                emit TransferSigned(msg.sender, amount, message); // Emit message
                return;
            }
        }
        revert("No unsigned transfers");
    }
}