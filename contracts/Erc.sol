// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./IERC20.sol";

contract ERC20 is IERC20 {
  uint totalTokens;
  address owner;
  mapping (address => uint) balances;
  mapping (address => mapping(address => uint)) allowances;
  string _name;
  string _symbol;

  function name() external view returns(string memory) {
    return _name;
  }

  function symbol() external view returns(string memory) {
    return _symbol;
  }

  function decimals() external pure returns(uint) {
    return 18; // 1 token = 1wei
  }

  function totalSupply() external view returns(uint) { // скіки усього в обороті
    return totalTokens;
  }

  modifier enoughTokens(address _from, uint _amount)  {
    require(balanceOf(_from) >= _amount, "Not enough tokens");
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "you are not owner");
    _;
  }

  function balanceOf(address account) public view returns(uint) { // скіки токенів на такому акаунті
    return balances[account];
  }

  constructor (string memory name_, string memory symbol_, uint initialSypply, address shop) {
    _name = name_;
    _symbol = symbol_;
    owner = msg.sender;
    mint(initialSypply, shop);
  }

  function transfer(address _to, uint _amount) external enoughTokens(msg.sender, _amount) {
    _beforeTokenTransfer(msg.sender, _to, _amount);
    balances[msg.sender] -= _amount;
    balances[_to] += _amount; 
    emit Transfer(msg.sender, _to, _amount);
  }

  function mint(uint amount, address shop) public onlyOwner {
    _beforeTokenTransfer(address(0), shop, amount);
    balances[shop] += amount; 
    totalTokens += amount;
    emit Transfer(address(0), shop, amount);
  }

  function burn(address _from, uint amount) public onlyOwner enoughTokens(_from, amount) {
    _beforeTokenTransfer(_from, address(0), amount);
    balances[_from] -= amount;
    totalTokens -= amount;
  }

  function allowance(address _owner, address spender) external view returns(uint) {
    return allowances[_owner][spender]; // я владе дозволяю цьому забрать таку кк токенів
  }

  function approve(address spender, uint amount) public {
    _approve(msg.sender, spender, amount);
  }

  function _approve(address sender, address spender, uint amount) internal virtual {
    allowances[sender][spender] = amount; // дозволяю з sender списать на spender стіки токенів
    emit Approve(sender, spender, amount);
  }

  function transferFrom(address sender, address recipient, uint amount) public enoughTokens(sender, amount) {
    _beforeTokenTransfer(sender, recipient, amount);

    allowances[sender][recipient] -= amount;
    balances[sender] -= amount;
    balances[recipient] += amount;

    emit Transfer(sender, recipient, amount);
   }



  function _beforeTokenTransfer(address _from, address _to, uint _amount) internal virtual {
    
  }


}

contract MONToken is ERC20 {
  constructor (address shop) ERC20("MONToken", "MON", 20, shop) {
  }
}

contract MONShop {
  IERC20 public token;
  address payable public owner;
  event Bought(uint _amount, address indexed _buyer);
  event Sold(uint _amount, address _seller);

  modifier onlyOwner() {
    require(msg.sender == owner, "you are not owner");
    _;
  }

  constructor() {
    token = new MONToken(address(this));
    owner = payable(msg.sender);
  }

  function sell(uint _amountToSell) external {
    require(_amountToSell > 0 && token.balanceOf(msg.sender) > _amountToSell, "incorrect amount");

    uint allowance = token.allowance(msg.sender, address(this));
    require(allowance >= _amountToSell, "Check allowance");

    token.transferFrom(msg.sender, address(this), _amountToSell);

    payable(msg.sender).transfer(_amountToSell); // платим

    emit Sold(_amountToSell, msg.sender);
  }

  receive() external payable {
    uint tokensToBuy = msg.value;
    require(tokensToBuy > 0, "buy more");

    require(tokenBalance() >= tokensToBuy, "not enouth tokens");

    token.transfer(msg.sender, tokensToBuy);
    emit Bought(tokensToBuy, msg.sender);
  }

  function tokenBalance() public view returns(uint) {
    return token.balanceOf(address(this));
  }

  function withdraw() public onlyOwner {
    owner.transfer(address(this).balance);
  }
}