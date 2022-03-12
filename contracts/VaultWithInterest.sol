// SPDX-License-Identifier: UNLICENSED"

pragma solidity ^0.8.0;

import "./Treasury.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract VaultWithInterest is Treasury {
    using SafeMath for uint256;

    /*
        Interest rate per second = 0.000000031709792 = 3.1709792e10-8
        calculated by dividing 1 by 31536000 (years in a second)
    */
    uint256 private constant RATE_PER_SECOND = 3.1709792e7;
    uint256 private constant SCALE_RATIO = 1e15;

    //This will be scaled by a factor of 1e15, handle the proper amount upon withdrawal
    mapping(address => uint256) public interestEarned;
    mapping(address => uint256) private lastInteractionTimestamp;

    modifier updateInterestEarned() {
        uint256 principle = getBorrowingPower(msg.sender);
        interestEarned[msg.sender] += calculateInterestEarned(
            principle,
            lastInteractionTimestamp[msg.sender],
            block.timestamp
        );
        lastInteractionTimestamp[msg.sender] = block.timestamp;
        _;
    }

    function deposit(uint256 _amount, address _tokenAddress)
        public
        override
        updateInterestEarned
    {
        super.deposit(_amount, _tokenAddress);
    }

    function withdrawInterest(uint256 _amount) public updateInterestEarned {
        uint256 _amountScaled = _amount * SCALE_RATIO;
        require(interestEarned[msg.sender] >= _amountScaled);
        _mint(msg.sender, _amountScaled.div(SCALE_RATIO));
        interestEarned[msg.sender] = interestEarned[msg.sender].sub(
            _amountScaled
        );
    }

    //Added this function to make this contract more testable for unit tests
    //This function will return the interest earned by a factor of 1e15
    function calculateInterestEarned(
        uint256 _principle,
        uint256 _startingTimestamp,
        uint256 _endingTimestamp
    ) public pure returns (uint256) {
        _principle *= SCALE_RATIO;
        return
            ((_principle.mul(RATE_PER_SECOND)).div(1e17)).mul(
                _endingTimestamp.sub(_startingTimestamp)
            );
    }
}
