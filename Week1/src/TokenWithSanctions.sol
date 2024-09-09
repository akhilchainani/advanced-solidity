pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenWithSanctions is ERC20 {
    mapping(address account => bool) private _bannedAccounts;

    address private _admin;

    constructor(string memory name_, string memory symbol_, address admin_) ERC20(name_, symbol_) {
        _admin = admin_;
    }

    /**
     * @dev Ban an account from using the token.
     */
    function banAccount(address account) public {
        require(msg.sender == _admin, "Only admin can ban accounts");
        _bannedAccounts[account] = true;
    }

    /**
     * @dev Unban an account from using the token.
     */
    function unbanAccount(address account) public {
        require(msg.sender == _admin, "Only admin can unban accounts");
        _bannedAccounts[account] = false;
    }

    /**
     * @dev Transfer tokens from one account to another. Override the transfer 
     * function to check if the sender or receiver is banned.

     * @notice This function is an override of the transfer function in the Starndard ERC20 token.
     */
    function transfer(address to, uint256 value) public virtual override returns (bool) {
        require(!_bannedAccounts[msg.sender], "Banned account");
        require(!_bannedAccounts[to], "Banned account");

        return super.transfer(to, value);
    }

    /**
     * @dev Transfer tokens from one account to another. Override the transferFrom 
     * function to check if the sender or receiver is banned.

     * @notice This function is an override of the transferFrom function in the Starndard ERC20 token.
     */
    function transferFrom(address from, address to, uint256 value) public virtual override returns (bool) {
        require(!_bannedAccounts[from], "Banned account");
        require(!_bannedAccounts[to], "Banned account");
        return super.transferFrom(from, to, value);
    }
}