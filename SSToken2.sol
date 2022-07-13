// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SSTestToken2 is ERC20 {
    bool public supplycontroled = false;
    
    constructor() ERC20("SSTest Token 2", "SSTest2") {
        //address adr2 = ;
         _mint(msg.sender,100000000*10 ** decimals());
         //_mint(adr2,1000*10**decimals());
         supplycontroled = true;
    }

    function decimals() public pure override returns (uint8) {
        return 0;
    }
    
    function approveDepositContract(address contractAddress) public{
        approve(contractAddress,balanceOf(msg.sender));
    }
    
    function mint() virtual external payable{
        require(!supplycontroled, "You can't mint anymore");
        _mint(msg.sender , msg.value);
    } 
}
