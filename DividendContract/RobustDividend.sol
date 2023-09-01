// ERC20 token contract
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract ERC20 {
    string public name;
    string public symbol;
    uint public totalSupply;
    uint public decimals;

    mapping(address=>mapping(address=> uint)) allowances;
    mapping(address=>uint) public balanceOf;


    uint scalingFactor = uint(10) ** 8;    
    mapping(address => uint) public scaledDividendBalanceOf; 
    mapping(address => uint) public scaledDividendCreditedTo;
    uint public scaledDividendPerToken;
    uint public scaledRemainder;
    
    
    
    event DividendPerTokenUpdated(uint amount);
    event updateDividendEVENT(address holder, uint amount, uint owed);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    
    
    constructor(string memory _name, string memory _symbol){
        name = _name;
        symbol = _symbol;
        _mint(1000);
    }

    // calculate dividend when money is deposited to the contract
    function deposit(uint _value) public payable {
        // store the dividend each time a deposit is made. 
        // stores the dividend perToken at the time of deposit.
        require(msg.value == _value, "The amount is not correct");
        uint amount = (msg.value * scalingFactor) + scaledRemainder;
        scaledDividendPerToken += amount/totalSupply;
        scaledRemainder = amount % totalSupply;
    }   


    // This method resets the dividend balance for the user and transfers them their share of the dividend. 
    function claimDividend() public payable {
        updateDividend(msg.sender); // takes all the dividend applicable when clicked. 
        //scale down the amount using the scaling factor;
        uint amount = scaledDividendBalanceOf[msg.sender] / scalingFactor;
        payable(msg.sender).transfer(amount);
        scaledDividendBalanceOf[msg.sender] %= scalingFactor;
    }

    /* 
       We need to figure out a way to calculate the amount of dividend and populate the dividendBalanceOf. 
       Since dividend depeneds on the ownership of the tokens. 
       Any time token ownership changes (transfer method call for simplicity), we calculate the amount of dividend owed to each token.

       function updateDividend(address holder) internal {
        uint owed = dividendPerToken * balanceOf[holder];
        dividendBalanceOf[msg.sender] += owed;
       } 

       Updating the dividend like this misses a key part. Holders can take dividend time to time. 
       Therefore, we must use another data structure to keep track of the dividend balance that is already credited to the user on each transfer.
       dividendCreditedTo is a mapping which aims to acheive this functionality.  
    */
    function updateDividend(address holder) internal {
        uint owed = scaledDividendPerToken - scaledDividendCreditedTo[holder];
        uint amount = owed * balanceOf[holder];
        emit updateDividendEVENT(holder, amount, owed);
        scaledDividendCreditedTo[holder] = scaledDividendPerToken;
        scaledDividendBalanceOf[holder] += amount;
    } 


    function _mint(uint amount) internal {
        require(msg.sender != address(0));
        totalSupply = amount * (uint(10) ** decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value) external returns (bool success) {
        require(balanceOf[msg.sender]>=value, "Insufficent Balance");
        updateDividend(to);
        updateDividend(msg.sender);
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to , value);
        return true; 
    }

    function transferFrom(address from, address to, uint value) external returns (bool success) {
            require(value <= balanceOf[from]);
            require(value <= allowances[from][msg.sender]);
            updateDividend(to);
            updateDividend(from);
            balanceOf[from] -= value;
            balanceOf[to] += value;
            allowances[from][msg.sender] -= value;
            emit Transfer(from, to , value);
            return true;
    }

    function approve(address spender, uint value) external returns (bool success) {
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender , value);
        return success;
    }
}
