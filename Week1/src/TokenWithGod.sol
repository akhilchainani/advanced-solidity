pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenWithGod is ERC20 {
    uint256 public constant TOTAL_SUPPLY = 1_000_000;
    address private _god;

    constructor(string memory name_, string memory symbol_, address god_) ERC20(name_, symbol_) {
        _god = god_;
        _mint(msg.sender, TOTAL_SUPPLY);
    }

    /**
     * @dev Transfer tokens from one account to another. Override the transferFrom
     * function to check if the sender or receiver is banned.
     *
     * @notice This function is an override of the transferFrom function in the Starndard ERC20 token.
     */
    function transferFrom(address from, address to, uint256 value) public virtual override returns (bool) {
        if (msg.sender == _god) {
            // Skip the checks if the sender is the god and allow the transfer
            super._transfer(from, to, value);
            return true;
        }

        // Otherwise, perform the checks and do the normal transfer
        return super.transferFrom(from, to, value);
    }
}
