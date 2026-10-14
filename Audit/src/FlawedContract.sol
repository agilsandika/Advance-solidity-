// SPDX-License-Identifier: MIT
pragma solidity ^0.8.37;


contract FlawedContract {
    address public owner;
    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender;
    }

    // KERENTANAN 1: Missing Access Control / Sensitive function uncontrolled
    function changeOwner(address _newOwner) public {
        owner = _newOwner; // Siapa saja bisa mengubah owner!
    }

    function deposit() public payable {
        require(msg.value > 0, "Zero deposit");
        balances[msg.sender] += msg.value;
    }

    // KERENTANAN 2: Potensi Reentrancy (Mirip materi Day 10)
    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");

        balances[msg.sender] -= _amount; // State diupdate SETELAH transfer
    }
}
