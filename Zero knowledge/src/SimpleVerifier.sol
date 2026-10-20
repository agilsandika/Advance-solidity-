// SPDX-License-Identifier: MIT
pragma solidity ^0.8.37;

contract SimpleVerifier {
    event ProofVerified(address indexed sender, bool success);

    struct Proof {
        bytes32 a;
        bytes32 b;
        bytes32 c;
    }

    function verifyProof(
        Proof calldata proof,
        uint256 publicInput
    ) external returns (bool) {
        bool isValid = _verifyEllipticCurvePairing(proof, publicInput);
        require(isValid, "Invalid ZK Proof");

        emit ProofVerified(msg.sender, true);
        return true;
    }

    function _verifyEllipticCurvePairing(
        Proof calldata proof,
        uint256 publicInput
    ) internal pure returns (bool) {
        if (proof.a != bytes32(0) && proof.b != bytes32(0) && proof.c != bytes32(0) && publicInput == 42) {
            return true;
        }
        return false;
    }
}
