// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Token} from "./Token.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MultiSignature} from "./MultiSignature.sol";

contract TransferToken is Ownable {
    Token public tokenBalance;
    IERC20 private token; //ERC20代币接口

    event transfered(address to, uint256 amount);

    uint256 constant conversionRatio = 1000; // 1 ETH = 1000 VoteToken
    address public tokenAccount;
    address constant lineaUsdtAddress =
        0xA219439258ca9da29E9Cc4cE5596924745e12B93;
    address private multiSignatureAddress;

    enum tokenId {
        USDT,
        ETH
    }

    constructor(
        address tokenAddress,
        address _multiSignatureAddress
    ) Ownable(msg.sender) {
        multiSignatureAddress = _multiSignatureAddress;
        token = IERC20(tokenAddress);
    }

    // 接收 ETH/USDT 并转换为 VoteToken
    function transferToken(
        uint32 tokenID,
        uint256 amount
    ) external payable returns (bool) {
        uint256 actuallyAmount;

        //转换倍率
        if (tokenID == uint8(tokenId.USDT)) {
            actuallyAmount = amount;
            require(msg.value >= amount, "Incorrect USDT amount sent");
        } else if (tokenID == uint8(tokenId.ETH)) {
            actuallyAmount = amount * conversionRatio;
            require(msg.value >= amount, "Incorrect ETH amount sent");
        } else {
            revert("Invalid tokenID");
        }

        require(
            actuallyAmount <= tokenBalance.getTokenAmount(),
            "Insufficient balance"
        );

        emit transfered(msg.sender, actuallyAmount);
        require(
            token.transferFrom(tokenAccount, msg.sender, actuallyAmount),
            "Transfer falied"
        );

        return true;
    }

    function withdrawETHwithMultisignature(
        address payable account,
        uint256 amount
    ) external {
        require(
            msg.sender == multiSignatureAddress,
            "Only MultiSignature Contract Can Withdraw"
        );
        require(address(this).balance >= amount, "Insufficient balance");
        (bool success, ) = account.call{value: amount}("");
        require(!success, "Transfer failed");
    }

    function withdrawUSDTwithMultisignature(
        address account,
        uint256 amount
    ) external {
        require(
            msg.sender == multiSignatureAddress,
            "Only MultiSignature Contract Can Withdraw"
        );
        IERC20 usdtToken = IERC20(lineaUsdtAddress);
        require(getContractUsdtBalance() >= amount, "Insufficient balance");
        bool success = usdtToken.transfer(account, amount);
        require(!success, "Transfer failed");
    }

    // 返回当前合约地址的 ETH 余额
    function getContractEthBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // 返回当前合约地址的 USDT 余额
    function getContractUsdtBalance() public view returns (uint256) {
        IERC20 usdtToken = IERC20(lineaUsdtAddress);
        return usdtToken.balanceOf(address(this));
    }

    //更新合约的token地址
    function updateTokenAddress(address newToken) external onlyOwner {
        token = IERC20(newToken);
    }
}
