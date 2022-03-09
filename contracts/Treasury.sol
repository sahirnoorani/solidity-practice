// SPDX-License-Identifier: UNLICENSED"

pragma solidity ^0.8.0;

import "./PUSD.sol";

contract Treasury is PUSD {
    mapping(address => mapping(ERC20 => uint256)) public depositorBalances;
    mapping(address => uint256) public outstandingLoans;
    address[] public depositorAddresses;
    ERC20[] public tokens;

    function deposit(uint256 _amount, address _tokenAddress) public {
        ERC20 token = ERC20(_tokenAddress);
        tokens.push(token);
        require(
            token.balanceOf(msg.sender) >= _amount,
            string(abi.encodePacked("You don't have enough ", token.name()))
        );
        depositorBalances[msg.sender][token] += _amount;
        depositorAddresses.push(msg.sender);
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function takeLoan(uint256 _requestedLoanAmount) public {
        require(
            getBorrowingPower(msg.sender) >= _requestedLoanAmount,
            "Insufficient collateral"
        );
        outstandingLoans[msg.sender] += _requestedLoanAmount;
        _mint(msg.sender, _requestedLoanAmount);
    }

    function getTokenCollateralBalance(address _tokenAddress)
        public
        view
        returns (uint256)
    {
        return depositorBalances[msg.sender][ERC20(_tokenAddress)];
    }

    function getOutstandingLoanAmount() public view returns (uint256) {
        return outstandingLoans[msg.sender];
    }

    function getBorrowingPower(address _address)
        private
        view
        returns (uint256)
    {
        uint256 borrowingPower = 0;
        for (uint256 i = 0; i < tokens.length; i++) {
            borrowingPower += depositorBalances[_address][tokens[i]];
        }
        return borrowingPower - outstandingLoans[_address];
    }
}
