// SPDX-License-Identifier: MIT
pragma solidity ^0.8.37;

import "forge-std/Test.sol";
import "../src/Vault.sol";

contract VaultInvariantTest is Test {
    Vault public vault;

    function setUp() public {
        vault = new Vault();
        // Beritahu Foundry kontrak mana saja yang akan diserang dengan aksi acak
        targetContract(address(vault));
    }

    /// @notice INVARIANT: Saldo total di kontrak harus selalu sama dengan jumlah totalDeposit internal
    function invariant_solidityBalanceMatchesTotalDeposit() public view {
        assertEq(address(vault).balance, vault.totalDeposit());
    }
}
