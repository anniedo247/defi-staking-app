// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Tether {
    string  public name = "Mock Tether Token";
    string  public symbol = "mUSDT";
    uint256 public totalSupply = 1000000000000000000000000; // 1 million tokens
    uint8   public decimals = 18;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint _value
    );

    event Approval (
        address indexed _owner,
        address indexed _spender,
        uint _value
    );

    mapping(address => uint) public balanceOf;
    mapping(address => mapping (address => uint)) public allowance;

    constructor() public {
      balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
       require(balanceOf[msg.sender] >= _value);
       balanceOf[msg.sender] -= _value;
       balanceOf[_to] += _value;
       emit Transfer(msg.sender,_to,_value);
       return true;
    }
    
    function approve (address _spender, uint256 _value) public returns (bool success) {
      allowance[msg.sender][_spender] = _value;
      emit Approval(msg.sender,_spender,_value);
      return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
      require(balanceOf[_from] >= _value);
      require(allowance[_from][msg.sender] >= _value);

      balanceOf[_from] -= _value;
      balanceOf[_to] += _value;
      //allowance[msg.sender][_from] -= _value;
      allowance[_from][msg.sender] -= _value;
      emit Transfer(_from,_to,_value);
      return true;
    }
}

// step1: customer (address A) allows stake x Tether into bank (address B)
// A.approve (B, x)
// sender = A, spender = B, value = x
// allowance [A] [B] = x

//step2: bank trigger staking of A into bank B, with T being staking pool address
// B.transferFrom(A, T, x)
// sender = B, from = A, to = T, value = x
// require allowance[A][B] >= x
// allowance [A][B] -= x
// balance[A] =- x
// balance[T] += x

// bank B has many tokens Tether, rwd, .... Tether has staking address T, rwd  has stakking a