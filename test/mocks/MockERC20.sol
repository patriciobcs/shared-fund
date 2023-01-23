// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    mapping(address => uint256) public _balances;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function reduceUserBalance(address _user, uint256 _amount) external {
        _balances[_user] -= _amount;
    }

    function increaseUserBalance(address _user, uint256 _amount) external {
        _balances[_user] += _amount;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
}

interface IMockERC20 {
    function reduceUserBalance(address _user, uint256 _amount) external;
    function increaseUserBalance(address _user, uint256 _amount) external;
}
