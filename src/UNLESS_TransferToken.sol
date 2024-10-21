// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SignatureVerifier} from "./UNLESS_SignatureVerifier.sol";

/**
 * @title TransferToken
 * @author xiongren
 * @notice 转账合约 用于给用户发送平台ERC20代币
 */
contract TransferToken is Ownable {
    IERC20 private token; //ERC20代币接口
    SignatureVerifier private verifier; //验证合约

    event transfered(address from, address to, uint256 amount);

    constructor(
        address tokenAddress, //代币地址
        address verifierAddress //验证签名的合约的地址
    ) Ownable(msg.sender) {
        verifier = SignatureVerifier(verifierAddress);
        token = IERC20(tokenAddress);
    }

    function transferWithSignature(
        uint amount,
        bytes memory signature,
        address messageTo
    ) external {
        require(
            verifier.verifySignature(signature, messageTo),
            "Invalid signature"
        );
        require(messageTo != address(0), "Invalid address");
        require(token.transfer(messageTo, amount), "Transfer falied");
        emit transfered(msg.sender, messageTo, amount);
    }

    function updateVerifier(address newVerifier) external onlyOwner {
        verifier = SignatureVerifier(newVerifier);
    }

    function updateTokenAddress(address newToken) external onlyOwner {
        token = IERC20(newToken);
    }
}
