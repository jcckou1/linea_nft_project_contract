// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TransferToken} from "../src/TransferToken.sol";
import {Token} from "../src/Token.sol";
import {SignatureVerifier} from "../src/SignatureVerifier.sol";

contract TransferTokenDeploy is Script {
    TransferToken public transferToken;
    Token public token;
    SignatureVerifier public signatureVerifier;

    address correctAddress = vm.envAddress("CORRECT_VERIFIER_ADDRESS");

    function run() external returns (TransferToken, Token, SignatureVerifier) {
        vm.startBroadcast();

        signatureVerifier = new SignatureVerifier(correctAddress);
        token = new Token();
        transferToken = new TransferToken(
            address(token),
            address(signatureVerifier)
        );

        vm.stopBroadcast();

        return (transferToken, token, signatureVerifier);
    }
}
