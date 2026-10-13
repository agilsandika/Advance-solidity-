// SPDX-License-Identifier: MIT
pragma solidity ^0.8.37;

import "forge-std/Test.sol";
import "../src/SimpleStaking.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}

contract StakingTest is Test {
    SimpleStaking public staking;
    MockToken public stakeToken;
    MockToken public rewardToken;

    address public alice = address(0x1);

    function setUp() public {
        stakeToken = new MockToken("Stake Token", "STK");
        rewardToken = new MockToken("Reward Token", "RWD");

        staking = new SimpleStaking(address(stakeToken), address(rewardToken));

        // Transfer reward token ke contract staking agar bisa dibagikan
        rewardToken.transfer(address(staking), 10000 ether);

        // Beri modal stake token ke Alice
        stakeToken.transfer(alice, 1000 ether);

        vm.startPrank(alice);
        stakeToken.approve(address(staking), type(uint256).max);
        vm.stopPrank();
    }

    function test_StakeAndEarnReward() public {
        vm.startPrank(alice);

        // 1. Alice melakukan stake 100 token
        staking.stake(100 ether);
        assertEq(staking.balanceOf(alice), 100 ether);

        vm.stopPrank();

        // 2. Simulasi waktu berjalan 10 detik menggunakan Foundry vm.warp
        vm.warp(block.timestamp + 10);

        // 3. Cek apakah reward bertambah
        uint256 earnedReward = staking.earned(alice);
        assertTrue(earnedReward > 0);

        // 4. Alice melakukan claim reward
        vm.startPrank(alice);
        staking.getReward();
        
        assertEq(rewardToken.balanceOf(alice), earnedReward);
        vm.stopPrank();
    }
}
