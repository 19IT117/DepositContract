// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "https://github.com/19IT117/SSTestToken/blob/main/Token.sol";

contract Deposit{
    
    SSTestToken token1;

    address public owner;
    uint32 public TVLocked;  
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

    constructor(address _contractaddress1){
        
        token1 = SSTestToken(_contractaddress1);
        owner = msg.sender;
        //t.transferFrom(owner,address(this),1000000);
    }

    function DepositToken(uint32 amount , uint256 timeperiod) external{
        address depositor = msg.sender;
        require(amount>=1000,"Deposit more");
        require(timeperiod>=10 , "Increase deposit time");
        token1.transferFrom(depositor,owner,amount);
        LockMapping[depositor].push(LockDetails({amount : amount , lockperiod : block.timestamp + timeperiod}));
        unchecked {
            TVLocked += amount;
        }
        
    }

    function ClaimTokens(uint256 index) external{
        address depositor = msg.sender;
        require(LockMapping[depositor][index].lockperiod<=block.timestamp , "you can't withdraw now");
        LockDetails storage s =  LockMapping[depositor][index];
        unchecked{
            TVLocked -= s.amount;    
        }
        token1.transferFrom(owner,depositor,(s.amount*110)/10);
        delete LockMapping[depositor][index];
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    function changeOwnership(address newOwner) external onlyOwner{
        require(token1.allowance(newOwner,address(this))>0,"Owner need to allow transferfrom");
        owner = newOwner;
    }


    function takeLoan() public payable{
        address loanTaker = msg.sender;
        uint32 amount = uint32(msg.value);
        require(TVLocked-TVLoaned <= amount && token1.allowance(owner,address(this))>= amount, "Insufficent fund in the contract");
        LoanMapping[loanTaker].push(LoanDetails({amount : amount , timestamp : block.timestamp}));
        token1.transfer(loanTaker,msg.value);
        unchecked{
            TVLoaned += amount;
            TVLocked -= amount ;
        }
    }

    function payLoan(uint index,uint32 amount) public payable{
        address payer =msg.sender;
        LoanDetails storage s = LoanMapping[payer][index];
        uint32  _amount = s.amount;
        require(amount == (_amount*112)/100,"You need to pay entire loan");
        require(block.timestamp<=s.timestamp +100, "You are late");
        token1.transferFrom(payer,address(this),amount);
        payable(payer).transfer(_amount);
        unchecked{
            TVLoaned -= _amount;
            TVLocked += _amount;

            ownerEarnings += (_amount*11)/100;
            contractReserve += (_amount*1)/100;
        }
        delete LoanMapping[payer][index];
    }

    function withdrawEarnings() public onlyOwner{
        require(ownerEarnings>0,"Nothing earned yet");
        token1.transfer(owner,ownerEarnings);
        ownerEarnings=0;
    }

    function balanceEth() public view returns (uint256){
        return address(this).balance;
    }
    
    function withdrawToken() public payable onlyOwner{
        token1.approve(owner,token1.balanceOf(address(this)));
    }

    function withdrawEth() public payable onlyOwner{
        payable(owner).transfer(balanceEth());
    }

    function fallback() external payable{

    }

}

