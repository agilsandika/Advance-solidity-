// SPDX-License-Identifier: MIT
pragma solidity ^0.8.37;

contract SimpleTimeLock {
    address public admin;
    uint256 public constant MIN_DELAY = 1 days;

    mapping(bytes32 => bool) public queuedTransactions;

    event TransactionQueued(bytes32 indexed txId, address target, uint256 value, bytes data, uint256 executeTime);
    event TransactionExecuted(bytes32 indexed txId, address target, uint256 value, bytes data);
    event TransactionCancelled(bytes32 indexed txId);

    error NotAdmin();
    error TxNotQueued();
    error TxNotReady();
    error TxAlreadyQueued();
    error ExecutionFailed();

    modifier onlyAdmin() {
        if (msg.sender != admin) revert NotAdmin();
        _;
    }

    constructor(address _admin) {
        admin = _admin;
    }

    receive() external payable {}

    function getTxId(address target, uint256 value, bytes calldata data, uint256 executeTime) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(target, value, data, executeTime));
    }

    function queueTransaction(address target, uint256 value, bytes calldata data, uint256 executeTime) external onlyAdmin returns (bytes32) {
        if (executeTime < block.timestamp + MIN_DELAY) revert TxNotReady();
        
        bytes32 txId = getTxId(target, value, data, executeTime);
        if (queuedTransactions[txId]) revert TxAlreadyQueued();

        queuedTransactions[txId] = true;

        emit TransactionQueued(txId, target, value, data, executeTime);
        return txId;
    }

    function executeTransaction(address target, uint256 value, bytes calldata data, uint256 executeTime) external payable onlyAdmin returns (bytes memory) {
        bytes32 txId = getTxId(target, value, data, executeTime);
        
        if (!queuedTransactions[txId]) revert TxNotQueued();
        if (block.timestamp < executeTime) revert TxNotReady();

        queuedTransactions[txId] = false;

        (bool success, bytes memory result) = target.call{value: value}(data);
        if (!success) revert ExecutionFailed();

        emit TransactionExecuted(txId, target, value, data);
        return result;
    }

    function cancelTransaction(address target, uint256 value, bytes calldata data, uint256 executeTime) external onlyAdmin {
        bytes32 txId = getTxId(target, value, data, executeTime);
        
        if (!queuedTransactions[txId]) revert TxNotQueued();

        queuedTransactions[txId] = false;

        emit TransactionCancelled(txId);
    }
}
