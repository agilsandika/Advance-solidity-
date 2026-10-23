// SPDX-License-Identifier: MIT
pragma solidity ^0.8.37;


interface IFlashLoanPool {
    function flashLoan(uint256 amount, bytes calldata data) external;
}

contract SimpleFlashLoanReceiver {
    address public immutable pool;

    error FlashLoanFailed();
    error UnauthorizedPool();

    constructor(address _pool) {
        pool = _pool;
    }

    function executeOperation(uint256 amount, bytes calldata data) external {
        if (msg.sender != pool) revert UnauthorizedPool();

        uint256 amountToRepay = amount + (amount * 1 / 1000); 

        _doSomethingProfitableWithFunds(amount);

        bool success = address(uint160(pool)).send(amountToRepay);
        if (!success) revert FlashLoanFailed();
    }

    function requestLoan(uint256 amount, bytes calldata data) external {
        IFlashLoanPool(pool).flashLoan(amount, data);
    }

    function _doSomethingProfitableWithFunds(uint256 amount) internal pure {
        uint256 _temp = amount;
        _temp = _temp + 1;
    }

    receive() external payable {}
}
