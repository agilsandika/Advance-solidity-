// SPDX-License-Identifier: MIT
pragma solidity ^0.8.37;

contract SimpleSmartWallet {
    address public owner;

    event Executed(address indexed target, uint256 value, bytes data);

    constructor(address _owner) {
        owner = _owner;
    }

    // Modifier untuk memastikan hanya owner atau kontrak itu sendiri yang bisa memanggil fungsi
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    /// @notice Memungkinkan smart wallet menerima Ether
    receive() external payable {}

    /// @notice Fungsi utama untuk mengeksekusi transaksi apa pun ke kontrak lain dari dompet ini
    function execute(address target, uint256 value, bytes calldata data) external onlyOwner returns (bytes memory) {
        (bool success, bytes memory result) = target.call{value: value}(data);
        require(success, "Execution failed");

        emit Executed(target, value, data);
        return result;
    }

    /// @notice Mengganti owner dompet (Fitur dasar manajemen kunci)
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid owner");
        owner = newOwner;
    }
}
