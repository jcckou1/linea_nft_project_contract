// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SignatureVerifier
 * @author xiongren
 * @notice 签名验证合约 用于验证后端的签名
 */
contract SignatureVerifier is Ownable {
    address s_corectSigner;

    constructor(address correctSigner) Ownable(msg.sender) {
        s_corectSigner = correctSigner;
    }

    function verifySignature(
        bytes memory signature,
        address message //一般为收款人地址
    ) external view returns (bool) {
        bytes32 messageHash = transferMassageToHash(message);

        address recoveredSigner = recoverSigner(messageHash, signature);

        return recoveredSigner == s_corectSigner;
    }

    function recoverSigner(
        bytes32 hash,
        bytes memory signature
    ) internal pure returns (address) {
        require(signature.length == 65, "Invalid signature lenth");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20)) // 加载签名中的 r
            s := mload(add(signature, 0x40)) // 加载签名中的 s
            v := byte(0, mload(add(signature, 0x60))) // 加载签名中的 v
        }

        return ecrecover(hash, v, r, s);
    }

    function transferMassageToHash(
        address message
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(message));
    }

    function setCorrectSigner(address newCorrectSigner) external onlyOwner {
        s_corectSigner = newCorrectSigner;
    }
}
