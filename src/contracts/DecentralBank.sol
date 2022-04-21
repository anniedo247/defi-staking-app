// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import './RWD.sol';
import './Tether.sol';

contract DecentralBank {
  string public name = "DecentralBank";
  address public owner;
  Tether public tether;
  RWD public rwd;
  
  address[] public stakers;

  mapping (address => uint) public stakingBalance;
  mapping(address => bool) public hasStaked;
  mapping(address => bool) public isStaking;

  constructor(RWD _rwd,Tether _tether) public {
    rwd = _rwd;
    tether = _tether;
    owner = msg.sender;
  }
  
  //staking function
  function depositTokens (uint _amount) public {
    //The transfer of 0 (zero) value must also be treated as a valid transfer and should fire the Transfer event.??????????

    require(_amount > 0, "amount can not be less than zero");  
    // Transfer tokens to this contract address for staking
    tether.transferFrom(msg.sender, address(this), _amount); //?????
    //Update staking balance
    stakingBalance[msg.sender] += _amount;

    if(!hasStaked[msg.sender]){
      stakers.push(msg.sender);
    }
    isStaking[msg.sender] = true;
    hasStaked[msg.sender] = true;
  }

  //unstaking function
  function unstakingTokens () public {
   uint balance = stakingBalance[msg.sender];
   require(balance > 0,'staking balance can not be less than zero');
   //transfer tokens to the specified contract address fro our bank
   tether.transfer(msg.sender,balance);

   stakingBalance[msg.sender] = 0;
   isStaking[msg.sender] = false;

  }

//issue rewards
  function issueTokens () public {
    //require the owner to issue tokens
    require(msg.sender == owner,'caller must be the owner');
    for (uint i=0; i <stakers.length; i++){
      address recipient = stakers[i];
      uint balance = stakingBalance[recipient]/10; //incentive percentage 1/10
      if(balance > 0){
         rwd.transfer(recipient, balance);
      }
    }
  }

  
}
