// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TransferToken} from "../src/TransferToken.sol";
import {Token} from "../src/Token.sol";
import {MultiSignature} from "../src/MultiSignature.sol";

contract TransferTokenDeploy is Script {
    TransferToken public transferToken;
    Token public token;
    MultiSignature public multisignature;
    address[] exmpleAddress = [0xAa924fE3E0277d1C5B508C476ce546377E202a3e];

    function run() external returns (TransferToken, Token, MultiSignature) {
        vm.startBroadcast();

        multisignature = new MultiSignature(exmpleAddress, 1);
        token = new Token();
        transferToken = new TransferToken(
            address(token),
            address(multisignature)
        );

        vm.stopBroadcast();

        return (transferToken, token, multisignature);
    }
}
