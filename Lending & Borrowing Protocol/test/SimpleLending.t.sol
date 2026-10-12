// SPDX-License-Identifier: MIT
pragma solidity ^0.8.37;

import "forge-std/Test.sol";
import "../src/SimpleLending.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}

contract LendingTest is Test {
    SimpleLending public lending;
    MockERC20 public collateralToken;
    MockERC20 public borrowToken;

    address public alice = address(0x1);

    function setUp() public {
        collateralToken = new MockERC20("Collateral Token", "COL");
        borrowToken = new MockERC20("Borrow Token", "BOR");

        lending = new SimpleLending(address(collateralToken), address(borrowToken));

        // Isi likuiditas borrow token ke contract lending agar bisa dipinjam
        borrowToken.transfer(address(lending), 5000 ether);

        // Beri modal token ke Alice
        collateralToken.transfer(alice, 1000 ether);

        vm.startPrank(alice);
        collateralToken.approve(address(lending), type(uint256).max);
        borrowToken.approve(address(lending), type(uint256).max);
        vm.stopPrank();
    }

    function test_DepositAndBorrow() public {
        vm.startPrank(alice);

        // 1. Alice deposit 100 Token Kolateral
        lending.depositCollateral(100 ether);
        assertEq(lending.collateralBalances(alice), 100 ether);

        // 2. Alice pinjam 50 Token Borrow (Maksimal LTV 75% dari 100 = 75 Token, jadi 50 aman)
        lending.borrow(50 ether);
        assertEq(lending.borrowBalances(alice), 50 ether);

        vm.stopPrank();
    }
}
