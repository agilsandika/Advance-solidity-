// SPDX-License-Identifier: MIT
pragma solidity ^0.8.37;

contract OptimizedGas {
    // Custom Error jauh lebih hemat dibanding string require
    error InvalidAmount();

    // Variable Packing: address (20 bytes) + uint64 (8 bytes) + uint64 (8 bytes) = 36 bytes (masuk dalam 2 slot efisien)
    address public owner;
    uint64 public id;
    uint64 public amount;

    constructor() {
        owner = msg.sender;
        id = 1;
        amount = 100;
    }

    function processPayment(uint256 val) public {
        if (val == 0) revert InvalidAmount();

        // Menggunakan unchecked jika aman dari overflow untuk menghemat gas aritmatika
        unchecked {
            id = uint64(val);
        }
    }
}
