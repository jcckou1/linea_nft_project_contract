// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {NarutoRole} from "../src/NarutoRole.sol";
import {Script} from "forge-std/Script.sol";

contract NarutoRoleDeploy is Script {
    NarutoRole public narutoRole;
    string Sasuke_Uchiha_Uri =
        "ipfs://QmSsYRx3LpDAb1GZQm7zZ1AuHZjfbPkD6J7s9r41xu1mf8";
    string Naruto_Uzumaki_Uri =
        "ipfs://QmSsYRx3LpDAb1GZQm7zZ1AuHZjfbPkD6J7s9r41xu1mf8";
    string Itachi_Uchiha_Uri =
        "ipfs://QmSsYRx3LpDAb1GZQm7zZ1AuHZjfbPkD6J7s9r41xu1mf8";

    function run() external returns (NarutoRole) {
        vm.startBroadcast();

        narutoRole = new NarutoRole(
            Sasuke_Uchiha_Uri,
            Naruto_Uzumaki_Uri,
            Itachi_Uchiha_Uri,
            "30",
            0
        );
        vm.stopBroadcast();
        return narutoRole;
    }
}
