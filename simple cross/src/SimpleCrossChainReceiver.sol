// SPDX-License-Identifier: MIT
pragma solidity ^0.8.37;

contract SimpleCrossChainReceiver {
    address public trustedBridge;
    string public lastMessage;

    event MessageReceived(address indexed sender, string message);

    constructor(address _trustedBridge) {
        trustedBridge = _trustedBridge;
    }

    /// @notice Fungsi yang hanya bisa dipanggil oleh bridge resmi untuk mencatat pesan dari chain lain
    function receiveCrossChainMessage(string calldata _message) external {
        // Keamanan: Memastikan pesan benar-benar datang dari jembatan terpercaya
        require(msg.sender == trustedBridge, "Only trusted bridge can call");

        lastMessage = _message;
        emit MessageReceived(msg.sender, _message);
    }
}
