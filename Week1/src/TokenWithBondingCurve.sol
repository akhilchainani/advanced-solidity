pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenWithBondingCurve is ERC20 {
    uint256 public constant INITIAL_PRICE = 0;
    uint256 public constant PRICE_INCREMENT = 1_000 gwei;
    uint256 public constant COOLDOWN_BLOCKS = 5;

    mapping(address => uint256) private lastInteractedBlock;

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    /**
     * @dev Get the current price of the token.
     * @dev The price increases linearly with the total supply of the token.
     */
    function getCurrentPrice() public view returns (uint256) {
        return INITIAL_PRICE + PRICE_INCREMENT * super.totalSupply();
    }

    /**
     * @dev Buy tokens from the contract by sending ether.
     */
    function buy(uint256 value) public payable {
        // Check if the sender has waited long enough since the last interaction
        require(block.number - lastInteractedBlock[msg.sender] >= COOLDOWN_BLOCKS, "Cooldown period has not elapsed");

        // Calculate the total cost of the tokens
        uint256 currentPrice = getCurrentPrice();
        uint256 totalCost = 0;
        for (uint256 i = 0; i < value; i++) {
            totalCost += currentPrice + PRICE_INCREMENT * i;
        }

        // Verify that the sender has sent enough ether
        require(msg.value >= totalCost, "Insufficient funds");

        // Update the last interacted block for the sender
        lastInteractedBlock[msg.sender] = block.number;

        // Mint the tokens to the sender as the last step
        super._mint(msg.sender, value);
    }

    /**
     * @dev Sell tokens to the contract and receive ether.
     */
    function sell(uint256 value) public {
        // Check if the sender has waited long enough since the last interaction
        require(block.number - lastInteractedBlock[msg.sender] >= COOLDOWN_BLOCKS, "Cooldown period has not elapsed");

        // Calculate the total payment for the tokens
        // Note: The current price to sell it is the last price the contract bought it for
        // which is the current price minus the price increment
        uint256 currentPrice = getCurrentPrice() - PRICE_INCREMENT;
        uint256 totalPayment = 0;
        for (uint256 i = 0; i < value; i++) {
            totalPayment += currentPrice - PRICE_INCREMENT * i;
        }

        // Verify that the contract has enough funds to pay the sender
        require(address(this).balance >= totalPayment, "Insufficient funds in the contract");

        // Transfer the ether to the sender
        (bool success, ) = msg.sender.call{value: totalPayment}("");
        require(success, "Transfer failed.");

        // Update the last interacted block for the sender
        lastInteractedBlock[msg.sender] = block.number;

        // Burn the tokens from the sender as the last step
        super._burn(msg.sender, value);
    }
}
