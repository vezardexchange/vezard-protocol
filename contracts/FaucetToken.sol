// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FaucetToken is ERC20 {
    uint8 _decimals;

    constructor(string memory name, string memory symbol, uint256 initial, uint8 decimal) ERC20(name, symbol){
        _mint(msg.sender, initial);
        _decimals = decimal;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    function faucet(uint256 amount) external {
        _mint(msg.sender, amount);
    }
}
