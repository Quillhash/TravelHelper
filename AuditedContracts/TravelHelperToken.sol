/**
 
 _____                   _   _   _      _                   _        _              
|_   _|                 | | | | | |    | |                 | |      | |             
  | |_ __ __ ___   _____| | | |_| | ___| |_ __   ___ _ __  | |_ ___ | | _____ _ __  
  | | '__/ _` \ \ / / _ \ | |  _  |/ _ \ | '_ \ / _ \ '__| | __/ _ \| |/ / _ \ '_ \ 
  | | | | (_| |\ V /  __/ | | | | |  __/ | |_) |  __/ |    | || (_) |   <  __/ | | |
  \_/_|  \__,_| \_/ \___|_| \_| |_/\___|_| .__/ \___|_|     \__\___/|_|\_\___|_| |_|
                                         | |                                        
                                         |_|                                        
                                                                 
**/

pragma solidity 0.4.24;
import "./StandardToken.sol";
import "./Ownable.sol";


contract TravelHelperToken is StandardToken, Ownable {


//Begin: state variables
    address public saleContract;
    string public constant name = "TravelHelperToken";
    string public constant symbol = "TRH";
    uint public constant decimals = 18;
    bool public fundraising = true;
    uint public totalReleased = 0;
    address public teamAddressOne;
    address public teamAddressTwo;
    address public marketingAddress;
    address public advisorsAddress;
    address public initialAdvisorAddress;
    uint public icoStartBlock;
    uint256 public tokensUnlockPeriod = 30; //37 days / 15; // 7 days presale + 30 days crowdsale
    uint public tokensSupply = 5000000000; // 5 billion
    uint public teamTokens = 1480000000 * 1 ether; // 1.48 billion
    uint public initialAdvisorTokens = 20000000 * 1 ether;
    uint public marketingTeamTokens = 500000000 * 1 ether; // 500 million
    uint public advisorsTokens = 350000000 * 1 ether; // 350 million
    uint public bountyTokens = 150000000 * 1 ether; //150 million
     uint public tokensForSale = 2500000000 * 1 ether; // 2.5 billion
    uint public releasedTeamTokens = 0;
    uint public releasedAdvisorsTokens = 0;
    uint public releasedMarketingTokens = 0;
    bool public tokensLocked = true;
    Ownable ownable;
    mapping (address => bool) public frozenAccounts;
   
 //End: state variables
 //Begin: events
    event FrozenFund(address target, bool frozen);
    event PriceLog(string text);
//End: events

//Begin: modifiers


    modifier manageTransfer() {
        if (msg.sender == owner) {
            _;
        }
        else {
            require(fundraising == false);
            _;
        }
    }
    
    modifier tokenNotLocked() {
      if (icoStartBlock > 0 && block.number.sub(icoStartBlock) > tokensUnlockPeriod) {
        tokensLocked = false;
        _;
      } else {
        revert();
      }
    
  }

//End: modifiers

//Begin: constructor
    function TravelHelperToken(
    address _tokensOwner,
    address _teamAddressOne,
    address _teamAddressTwo,
    address _marketingAddress,
    address _advisorsAddress,
    address _initialAdvisorAddress) public Ownable(_tokensOwner) {
        require(_tokensOwner != 0x0);
        require(_teamAddressOne != 0x0);
        require(_teamAddressTwo != 0x0);
        teamAddressOne = _teamAddressOne;
        teamAddressTwo = _teamAddressTwo;
        advisorsAddress = _advisorsAddress;
        marketingAddress = _marketingAddress;
        initialAdvisorAddress = _initialAdvisorAddress;
        totalSupply = tokensSupply * (uint256(10) ** decimals);

    }

   

//End: constructor

    

//Begin: overriden methods

    function transfer(address _to, uint256 _value) public manageTransfer onlyPayloadSize(2) returns (bool success) {
        require(_to != address(0));
        require(!frozenAccounts[msg.sender]);
        super.transfer(_to,_value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)
        public
        manageTransfer
        onlyPayloadSize(3) returns (bool)
    {
        require(_to != address(0));
        require(_from != address(0));
        require(!frozenAccounts[msg.sender]);
        super.transferFrom(_from,_to,_value);
        return true;

    }



//End: overriden methods


//Being: setters
   
    function activateSaleContract(address _saleContract) public onlyOwner {
    require(tokensForSale > 0);
    require(teamTokens > 0);
    require(_saleContract != address(0));
    require(saleContract == address(0));
    saleContract = _saleContract;
    uint  totalValue = teamTokens.mul(50).div(100);
    balances[teamAddressOne] = balances[teamAddressOne].add(totalValue);
    balances[teamAddressTwo] = balances[teamAddressTwo].add(totalValue);
    balances[advisorsAddress] = balances[advisorsAddress].add(advisorsTokens);
    balances[initialAdvisorAddress] = balances[initialAdvisorAddress].add(initialAdvisorTokens);
    balances[marketingAddress] = balances[marketingAddress].add(marketingTeamTokens);
    releasedTeamTokens = releasedTeamTokens.add(teamTokens);
    releasedAdvisorsTokens = releasedAdvisorsTokens.add(advisorsTokens);
    releasedMarketingTokens = releasedMarketingTokens.add(marketingTeamTokens);
    balances[saleContract] = balances[saleContract].add(tokensForSale);
    totalReleased = totalReleased.add(tokensForSale).add(teamTokens).add(advisorsTokens).add(initialAdvisorTokens).add(marketingTeamTokens);
    tokensForSale = 0; 
    teamTokens = 0; 
    icoStartBlock = block.number;
    assert(totalReleased <= totalSupply);
    emit Transfer(address(this), teamAddressOne, totalValue);
    emit Transfer(address(this), teamAddressTwo, totalValue);
    emit Transfer(address(this), saleContract, 2500000000 * 1 ether);
    emit SaleContractActivation(saleContract, 2500000000 * 1 ether);
  }
  
 function saleTransfer(address _to, uint256 _value) public returns (bool) {
    require(saleContract != address(0));
    require(msg.sender == saleContract);
    return super.transfer(_to, _value);
  }
  
  
  function burnTokensForSale() public returns (bool) {
    require(saleContract != address(0));
    require(msg.sender == saleContract);
    uint256 tokens = balances[saleContract];
    require(tokens > 0);
    require(tokens <= totalSupply);
    balances[saleContract] = 0;
    totalSupply = totalSupply.sub(tokens);
    emit Burn(saleContract, tokens);
    return true;
  }
  
   
 
    

    function finalize() public {
        require(fundraising != false);
        require(msg.sender == saleContract);
        // Switch to Operational state. This is the only place this can happen.
        fundraising = false;
    }

   function freezeAccount (address target, bool freeze) public onlyOwner {
        require(target != 0x0);
        require(freeze == (true || false));
        frozenAccounts[target] = freeze;
        emit FrozenFund(target, freeze); // solhint-disable-line
    }
    
    function sendBounty(address _to, uint256 _value) public onlyOwner returns (bool) {
    uint256 value = _value.mul(1 ether);
    require(bountyTokens >= value);
    totalReleased = totalReleased.add(value);
    require(totalReleased <= totalSupply);
    balances[_to] = balances[_to].add(value);
    bountyTokens = bountyTokens.sub(value);
    emit Transfer(address(this), _to, value);
    return true;
  }
 /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) onlyOwner public  {
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner); // solhint-disable-line
        
    }
//End: setters
   
    function() public {
        revert();
    }

}
