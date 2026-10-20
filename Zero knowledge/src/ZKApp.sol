// SPDX-License-Identifier: MIT
pragma solidity ^0.8.37;

import "./SimpleVerifier.sol";

contract ZKApp {
    SimpleVerifier public immutable verifier;
    mapping(bytes32 => bool) public usedNullifiers;

    event SecretActionExecuted(address indexed user, bytes32 nullifierHash);

    error NullifierAlreadyUsed();
    error ProofValidationFailed();

    constructor(address _verifierAddress) {
        verifier = SimpleVerifier(_verifierAddress);
    }

    function executePrivateAction(
        SimpleVerifier.Proof calldata proof,
        uint256 publicInput,
        bytes32 nullifierHash
    ) external returns (bool) {
        if (usedNullifiers[nullifierHash]) {
            revert NullifierAlreadyUsed();
        }

        bool success = verifier.verifyProof(proof, publicInput);
        if (!success) {
            revert ProofValidationFailed();
        }

        usedNullifiers[nullifierHash] = true;

        emit SecretActionExecuted(msg.sender, nullifierHash);
        return true;
    }
}
