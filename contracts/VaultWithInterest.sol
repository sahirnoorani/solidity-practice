// SPDX-License-Identifier: UNLICENSED"

pragma solidity ^0.8.0;

import "./Treasury.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract VaultWithInterest is Treasury {
    using SafeMath for uint256;

    /*
        Interest rate per second = 0.000000031709792 = 3.1709792e10-8
        calculated by dividing 1 by 31536000 (years in a second)
        31536000 => 3.2e7
    */
    uint256 private constant RATE_PER_SECOND = 3.170979e7;
    uint256 private constant SCALE_RATIO = 1e15;

    //This will be scaled by a factor of 1e15, handle the proper amount upon withdrawal
    mapping(address => uint256) public interestEarned;
    mapping(address => uint256) private lastInteractionTimestamp;

    modifier updateInterestEarned() {
        uint256 totalDepositsToPercision = getBorrowingPower(msg.sender) *
            SCALE_RATIO;
        interestEarned[msg.sender] += (
            (totalDepositsToPercision.mul(RATE_PER_SECOND)).div(1e16)
        ).mul((block.timestamp.sub(lastInteractionTimestamp[msg.sender])));
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
}
