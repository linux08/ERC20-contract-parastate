pragma solidity >=0.4.0 <0.6.0;

// SPDX-License-Identifier: MIT

// pragma solidity 0.4.0;

/**
 * @title ERC20Basic
 *@dev simpler version of erc2o interface
 *@dev see https:
 */

contract ERC20Basic {
    function totalSUpply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transer(address to, uint256 value) public returns (bool);
    event Tranfer(address indexed from, address indexed to, uint256 value);
}

/**
 *@title  Basic token
 *@dev Basic version of standard token with no allowances
 */

contract BasicToken is ERC20Basic {

    mapping(address => uint256) balances;
    uint256 totalSupply_;

    /**
     * @dev total number of tokens in existence
     */

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
     * @dev get the balance of a specified address
     *
     */

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        // Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev get the balance of a specified address
     *
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return uint256(balances[_owner]);
    }
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender)
        public
        view
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract StandardToken is ERC20, BasicToken {
    mapping(address => mapping(address => uint256)) internal allowed;

    /***
     * @dev transfer tokens from one address to another
     *@param _from address to which you are sending the token from
     *@param _to address to which you want to transfer to
     *@param _value uint256 the amount of token to be transferred
     */

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from] - _value;
        balances[_to] = balances[_to] + _value;
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;
        // Transfer(_from, _to, _value);
        return true;
    }

    /**
     *@dev approvess the passed address
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     *@dev fn to check amount of token that are allowed to a spender
     */
    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /**
     *@dev fn to increase the amount of token an owner is allowed to spend
     */
    function increaseApproval(address _spender, uint256 _addedValue)
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] =
            allowed[msg.sender][_spender] +
            _addedValue;
       emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     *@dev fn to decrease the amount of token an owner is allowed to spend
     */
    function decreaseApproval(address _spender, uint256 _subtractedValue)
        public
        returns (bool)
    {
        uint256 oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue - _subtractedValue;
        }
       emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}

/*
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev the ownable constructor set the original ownere of the contract to send
     */
    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
         require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
      require(newOwner != address(0));
     emit OwnershipTransferred(owner,newOwner);
      owner = newOwner;
    }
}

contract Pausable is Ownable {


  event Paused();
  event UnPaused();

  bool public paused = false;

  modifier stopInEmergency { if (!paused) _; }
  modifier onlyInEmergency { if (paused) _; }


  /**
  * @dev modifier to make a fxn callable only when the contract is paused
   */

   modifier whenNotPaused(){
     require(!paused);
     _;
   }

      modifier whenPaused(){
     require(paused);
     _;
   }

  function pause()  onlyOwner whenNotPaused public {
    paused = true;
   emit Paused();
  }

  
  function pause()  onlyOwner whenNotPaused public {
    paused = false;
    emit UnPaused();
  }

}

contract PausableToken is StandardToken, Pausable{

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool){
    return super.transer(_to,_value);
  }

  function transferFrom(address _to, uint256 _value) public whenNotPaused returns (bool){
    return super.transer(_to,_value);
  }

 function approve(address _spender, uint256 _value) public whenNotPaused returns (bool){
    return super.transer(_spender,_value);
  }

  function increaseApproval(address _to, uint256 _addedValue) public whenNotPaused returns (bool){
    return super.transer(_to,_addedValue);
  }

   function decreaseApproval(address _to, uint256 _subtractedValue) public whenNotPaused returns (bool){
    return super.transer(_to,_subtractedValue);
  }

}

contract TestToken is PausableToken {

  string public name = "Test Token";
  string public symbol = "TTT";
  uint public decimals = 10;
  uint public totalSupply = 100000000000000000000;

  constructor () public {
    balances[msg.sender] = totalSupply;
  }
}

