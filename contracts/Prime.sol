// SPDX-License-Identifier: UNLICENSED"

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Prime is ERC20 {
    constructor() ERC20("Prime", "PME") {
        _mint(msg.sender, 10000000);
    }
}
