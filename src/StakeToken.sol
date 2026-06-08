// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title StakeToken
/// @notice A minimal ERC-20 token for testing and local deployment of the staking system.
/// @dev Owner can mint tokens freely; useful for seeding test accounts.
contract StakeToken is ERC20, Ownable {
    constructor(string memory name_, string memory symbol_, address initialOwner)
        ERC20(name_, symbol_)
        Ownable(initialOwner)
    {}

    /// @notice Mint tokens to a specified address. Only callable by the owner.
    /// @param to Recipient address.
    /// @param amount Amount of tokens to mint (in wei units).
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
