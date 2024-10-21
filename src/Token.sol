// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Token
 * @author xiongren
 * @notice 投票代币合约 用于铸造ERC20代币 可直接mint
 */
contract Token is ERC20, Ownable {
    address owner;

    constructor() ERC20("VoteToken", "VT") Ownable(msg.sender) {
        owner = msg.sender;
    }

    function mint(uint256 initialSupply) external onlyOwner {
        _mint(msg.sender, initialSupply);
    }

    function tokenApprove(
        address spenderAddress,
        uint256 amount
    ) public onlyOwner {
        _approve(msg.sender, spenderAddress, amount, true);
    }

    function getTokenAmount() external view returns (uint256) {
        return balanceOf(msg.sender);
    }
}
