// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FeatureToken is ERC20 {
    // contract will create by FeatureFactory.
    // Will set mintController as msg.sender;
    constructor() ERC20("Feature is feature", "Feature") {
        uint256 initialSupply = 10**9 * 10**18;
        _mint(msg.sender, initialSupply);
    }
}
