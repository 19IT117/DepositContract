// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "https://github.com/19IT117/SSTestToken/blob/main/Token.sol";

contract Deposit{
    
    SSTestToken token1;
    SSTestToken token2;

    address public owner;
    uint32 public TVLocked;
    uint32 public ownerBalance;
    uint32 public interestPayable;
    uint32 public ownerEarnings;
    uint32 public contractReserve;
    uint32 public TVLoaned;
    
    struct LockDetails {
        uint32 amount;
        uint256 lockperiod;
    }

    struct LoanDetails{
        uint32 amount;
        uint256 timestamp;
    }

    mapping(address => LockDetails[]) public LockMapping;
    mapping(address => LoanDetails[]) public LoanMapping;
    
    constructor(address _contractaddress1, address _contractaddress2){
        token1 = SSTestToken(_contractaddress1);
        token2 = SSTestToken(_contractaddress2);
        owner = msg.sender;
        //t.transferFrom(owner,address(this),1000000);
    }

    function DepositToken(uint32 amount , uint256 timeperiod) external{
        require(amount>=1000,"Deposit more than 1000");
        require(timeperiod>=10 , "Need to deposit more than 10 Seconds");
        token1.transferFrom(msg.sender,address(this),amount);
        LockMapping[msg.sender].push(LockDetails({amount : amount , lockperiod : block.timestamp + timeperiod}));
        TVLocked += amount;
        interestPayable += (amount * 10)/100;
        require(ownerBalance>interestPayable, "Sorry Deposit can't be done please try later.");
    }

    function ClaimTokens(uint256 index) external{
        require(LockMapping[msg.sender][index].lockperiod<=block.timestamp, "you can't withdraw now");
        LockDetails storage s =  LockMapping[msg.sender][index];
        TVLocked -= s.amount;
        interestPayable -= (s.amount * 10)/100;
        ownerBalance -= (s.amount * 10)/100;    
        token1.transfer(msg.sender,(s.amount*11)/10);
        delete LockMapping[msg.sender][index];
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    function changeOwnership(address newOwner) external onlyOwner{
        token1.transferFrom(newOwner,address(this),ownerBalance);
        owner = newOwner;
        token1.transfer(owner,ownerBalance);
    }

    function ownerDeposit(uint32 amount) external onlyOwner{
        token1.transferFrom(owner,address(this),amount);
        ownerBalance += amount;
    }

    function revokeDeposit(uint32 amount) external onlyOwner{
        require(amount<interestPayable , "Deposit can cause trouble for the project");
        token1.transfer(owner,amount);
        ownerBalance -= amount;
    }

    function takeLoan(uint32 amount) public{
        require(TVLocked-TVLoaned <= amount, "Insufficent fund in the contract");
        LoanMapping[msg.sender].push(LoanDetails({amount : amount , timestamp : block.timestamp}));
        token2.transferFrom(msg.sender,address(this),amount);
        token1.transfer(msg.sender,amount);
       
        TVLoaned += amount;
        TVLocked -= amount ;
    }

    function payLoan(uint index,uint32 amount) public {
        LoanDetails storage s =LoanMapping[msg.sender][index];
        uint32  _amount = s.amount;
        require(amount == (_amount*112)/100,"You need to pay entire loan");
        require(block.timestamp<=s.timestamp+100, "You are late");
        token1.transferFrom(msg.sender,address(this),amount);
        token2.transfer(msg.sender,_amount);
        TVLoaned -= _amount;
        TVLocked += _amount;
        ownerEarnings += (_amount*11)/100;
        contractReserve += (_amount*1)/100;
        delete LoanMapping[msg.sender][index];
    }

    function withdrawEarnings() public onlyOwner{
        require(ownerEarnings>0,"Nothing earned yet");
        token1.transfer(owner,ownerEarnings);
        ownerEarnings=0;
    }

}

