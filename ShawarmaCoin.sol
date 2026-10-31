// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ShawarmaCoin {
    //the special property in my smart contract is that we have a tax collector called Fanum which takes 10% of every transaction amount
    address public fanum;
    address public owner;
    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;
    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    event Approval(address indexed account, address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
        balances[owner] = 200*10**18;
        totalSupply = 200*10**18;
        fanum = address(0);
    }

    function setFanum(address account) public onlyOwner{
        require(account != address(0) , "Invalid fanum address");
        fanum = account;
    }

    modifier onlyOwner { 
        require(msg.sender == owner, "Not owner");
        _;
    }

    function transfer(address recipient, uint256 amount) public returns (bool){
        require(fanum != address(0) , "Fanum has not been set");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(recipient != address(0) , "Invalid address");
        uint256 fanumTax = amount/10;
        if (fanum == recipient) {
            fanumTax = 0;
        }
        balances[fanum] += fanumTax;
        balances[msg.sender] -= amount;
        balances[recipient] += (amount - fanumTax);
        
        emit Transfer(msg.sender, recipient, (amount - fanumTax));
        emit Transfer(msg.sender, fanum, fanumTax);
        return true;
    }

    function approve(address reciever, uint256 amount) public returns (bool){
        require(reciever != address(0), "Invalid spender");
        allowances[msg.sender][reciever] = amount; 
        emit Approval(msg.sender, reciever, amount);
        return true;
    }

    function transferFrom(address spender, address recipient, uint256 amount) public returns (bool){
        require(spender != address(0) , "Spender has not been set");        
        require(fanum != address(0) , "Fanum has not been set");        
        require(recipient != address(0) , "Invalid address");
        require(balances[spender] >= amount, "Insufficient balance");
        require(allowances[spender][msg.sender] >= amount, "Insufficient allowance");
        uint256 fanumTax = amount / 10;
        if (fanum == recipient) {
            fanumTax = 0;
        }
        balances[fanum] += fanumTax;
        balances[spender] -= amount;
        balances[recipient] +=  (amount -fanumTax);
        allowances[spender][msg.sender] -= amount;
        emit Transfer(spender, recipient, (amount-fanumTax));
        emit Transfer(spender, fanum, fanumTax);
        return true;
    }

    function mint(address recipient, uint256 amount) public onlyOwner{
        require(recipient != address(0) , "Invalid address");
        balances[recipient] += amount ; 
        totalSupply += amount;
        emit Transfer(address(0) , recipient, amount);
    }

    function balanceOf(address account) public view returns(uint256) {
        return balances[account];
    }

    function allowance(address account, address user) public view returns(uint256) {
    return allowances[account][user];
}

}