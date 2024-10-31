// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
// import "../interfaces/IERC20.sol";

contract ERC20Facet is IERC20{
    using Math for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    // function transfer(address recipient, uint256 amount) public override returns (bool) {
    //     require(recipient != address(0), "Transfer to the zero address");
    //     require(_balances[msg.sender] >= amount, "Insufficient balance");

    //     _balances[msg.sender] = _balances[msg.sender].sub(amount);
    //     _balances[recipient] = _balances[recipient].add(amount);

    //     emit Transfer(msg.sender, recipient, amount);
    //     return true;
    // }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
    require(recipient != address(0), "Transfer to the zero address");
    require(_balances[msg.sender] >= amount, "Insufficient balance");

    _balances[msg.sender] -= amount;
    _balances[recipient] += amount;

    emit Transfer(msg.sender, recipient, amount);
    return true;
}


    function approve(address spender, uint256 amount) public override returns (bool) {
        require(spender != address(0), "Approve to the zero address");

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
    //     require(sender != address(0), "Transfer from the zero address");
    //     require(recipient != address(0), "Transfer to the zero address");
    //     require(_balances[sender] >= amount, "Insufficient balance");
    //     require(_allowances[sender][msg.sender] >= amount, "Allowance exceeded");

    //     _balances[sender] = _balances[sender].sub(amount);
    //     _balances[recipient] = _balances[recipient].add(amount);
    //     _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);

    //     emit Transfer(sender, recipient, amount);
    //     return true;
    // }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
    require(sender != address(0), "Transfer from the zero address");
    require(recipient != address(0), "Transfer to the zero address");
    require(_balances[sender] >= amount, "Insufficient balance");
    require(_allowances[sender][msg.sender] >= amount, "Allowance exceeded");

    _balances[sender] -= amount;
    _balances[recipient] += amount;
    _allowances[sender][msg.sender] -= amount;

    emit Transfer(sender, recipient, amount);
    return true;
}


    // function mint(address account, uint256 amount) external {
    //     require(account != address(0), "Mint to the zero address");

    //     _totalSupply = _totalSupply.add(amount);
    //     _balances[account] = _balances[account].add(amount);

    //     emit Transfer(address(0), account, amount);
    // }

    function mint(address account, uint256 amount) external {
    require(account != address(0), "Mint to the zero address");

    _totalSupply += amount; 
    _balances[account] += amount; 

    emit Transfer(address(0), account, amount);
}

}
