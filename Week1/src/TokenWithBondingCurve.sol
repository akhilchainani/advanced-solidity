pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenWithBondingCurve is ERC20 {
    uint256 public constant INITIAL_PRICE = 0;
    uint256 public constant PRICE_INCREMENT = 1_000 gwei;
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
    }

    function getCurrentPrice() public view returns (uint256) {
        return INITIAL_PRICE + PRICE_INCREMENT * super.totalSupply();
    }

    /**
     * @dev Buy tokens from the contract by sending ether.
     */
    function buy(uint256 value) public payable {
        uint256 currentPrice = getCurrentPrice();
        uint256 totalCost = 0;
        for (uint256 i = 0; i < value; i++) {
            totalCost += currentPrice + PRICE_INCREMENT * i;
        }
        require(msg.value >= totalCost, "Insufficient funds");
        super._mint(msg.sender, value);
    }

    /**
     * @dev Sell tokens to the contract and receive ether.
     */
    function sell(uint256) public payable {
        uint256 currentPrice = getCurrentPrice();
        uint256 totalPayment = 0;
        for (uint256 i = 0; i < msg.value; i++) {
            totalPayment += currentPrice - PRICE_INCREMENT * i;
        }
    }
}