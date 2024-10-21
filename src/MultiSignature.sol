// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract MultiSignature {
    address[] public owners; //签名人列表
    uint256 public minSignatures; //最少签名人数

    struct Transaction {
        address targetContractAddress;
        uint256 amount;
        bytes data;
        bool executed;
        uint256 confirmationCount;
    }
    Transaction[] public transactions;

    mapping(uint256 txId => mapping(address txAddress => bool)) isConfirmed;

    constructor(address[] memory _owners, uint256 _minSignatures) {
        require(_owners.length > 1, "Onwers Required Must Be Greater than 1");
        require(
            _minSignatures > 0 && _minSignatures <= _owners.length,
            "Num of confirmations are not in sync with the number of owners"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid Owner");
            owners.push(_owners[i]); //保存可用签名人地址
        }

        minSignatures = _minSignatures; //保存最少签名人数
    }

    function isSigner(address _address) public view returns (bool) {
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == _address) {
                return true;
            }
        }
        return false;
    }

    modifier onlySigner() {
        require(isSigner(msg.sender), "Not a Signer");
        _;
    }

    function submitTransaction(
        address _targetContractAddress,
        uint256 _amount,
        bytes memory _data
    ) external onlySigner {
        require(_targetContractAddress != address(0), "Invalid Address");
        require(_amount > 0, "Invalid Amount");

        transactions.push(
            Transaction({
                targetContractAddress: _targetContractAddress,
                amount: _amount,
                data: _data,
                executed: false,
                confirmationCount: 0
            })
        );
    }

    function confirmTransaction(uint256 _txId) external onlySigner {
        Transaction storage transaction = transactions[_txId];

        require(_txId < transactions.length, "Invalid Transaction");
        require(!isConfirmed[_txId][msg.sender], "Already Confirmed");
        require(!transaction.executed, "Already Executed");

        transaction.confirmationCount += 1; //成功进行一次确认
        isConfirmed[_txId][msg.sender] = true; //记录某个签名人已成功签名

        if (transaction.confirmationCount >= minSignatures) {
            executeTransaction(_txId);
        }
    }

    function executeTransaction(uint256 _txId) public {
        Transaction storage transaction = transactions[_txId];

        require(
            transaction.confirmationCount >= minSignatures,
            "Not Enough Confirmations"
        );
        require(!transaction.executed, "Already Executed");

        transaction.executed = true; //标记交易已执行

        (bool success, ) = transaction.targetContractAddress.call{
            value: transaction.amount
        }(transaction.data);
        require(success, "Transaction Failed");
    }
}
