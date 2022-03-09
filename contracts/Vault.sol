// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Vault {
    ERC20 private token;
    mapping(address => uint256) public depositerAmounts;
    address[] public depositers;

    constructor(address _tokenAddress) {
        token = ERC20(_tokenAddress);
    }

    function deposit(uint256 _amount) public {
        require(
            token.balanceOf(msg.sender) >= _amount,
            string(abi.encodePacked("You don't have enough ", token.name()))
        );
        depositerAmounts[msg.sender] += _amount;
        depositers.push(msg.sender);
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function getUserBalance() public view returns (uint256) {
        return depositerAmounts[msg.sender];
    }
}
