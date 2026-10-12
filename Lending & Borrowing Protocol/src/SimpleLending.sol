// SPDX-License-Identifier: MIT
pragma solidity ^0.8.37;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleLending {
    IERC20 public immutable collateralToken; // Token Jaminan (misal: USDC/TokenA)
    IERC20 public immutable borrowToken;    // Token Pinjaman (misal: DAI/TokenB)

    mapping(address => uint256) public collateralBalances;
    mapping(address => uint256) public borrowBalances;

    // LTV 75% (dalam persentase basis 100)
    uint256 public constant LTV = 75; 

    constructor(address _collateralToken, address _borrowToken) {
        collateralToken = IERC20(_collateralToken);
        borrowToken = IERC20(_borrowToken);
    }

    /// @notice Menyetorkan token sebagai jaminan (collateral)
    function depositCollateral(uint256 _amount) external {
        require(_amount > 0, "Amount must be > 0");
        collateralToken.transferFrom(msg.sender, address(this), _amount);
        collateralBalances[msg.sender] += _amount;
    }

    /// @notice Meminjam token berdasarkan jaminan yang dimiliki
    function borrow(uint256 _borrowAmount) external {
        uint256 collateral = collateralBalances[msg.sender];
        require(collateral > 0, "No collateral deposited");

        // Hitung batas maksimal pinjaman berdasarkan LTV (75%)
        uint256 maxBorrow = (collateral * LTV) / 100;
        
        require(borrowBalances[msg.sender] + _borrowAmount <= maxBorrow, "Exceeds LTV limit");
        require(borrowToken.balanceOf(address(this)) >= _borrowAmount, "Insufficient liquidity in pool");

        borrowBalances[msg.sender] += _borrowAmount;
        borrowToken.transfer(msg.sender, _borrowAmount);
    }

    /// @notice Melunasi pinjaman
    function repay(uint256 _repayAmount) external {
        require(_repayAmount > 0, "Amount must be > 0");
        borrowToken.transferFrom(msg.sender, address(this), _repayAmount);
        borrowBalances[msg.sender] -= _repayAmount;
    }
}
