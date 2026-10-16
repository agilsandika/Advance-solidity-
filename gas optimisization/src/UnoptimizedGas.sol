// SPDX-License-Identifier: MIT
pragma solidity ^0.8.37;

contract UnoptimizedGas {
    // Variabel tidak di-pack (memakai banyak slot storage terpisah)
    uint256 public id = 1;
    uint256 public amount = 100;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function processPayment(uint256 val) public {
        // Menggunakan string require yang panjang (mahal gas)
        require(val > 0, "Nilai pembayaran harus lebih besar dari nol");
        
        id = val;
    }
}
