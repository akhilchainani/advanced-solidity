pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UntrustedEscrow {
    uint256 public constant ESCROW_DURATION = 3 days;

    struct Escrow {
        uint256 withdrawableBlockNumber;
        address buyer;
        address seller;
        IERC20 token;
        uint256 amount;
        bool isFullyRedeemed;
    }

    mapping(uint256 => Escrow) private escrows;
    uint256 private escrowCount;

    event EscrowCreated(uint256 id, address buyer, address seller, IERC20 token, uint256 amount);
    event EscrowRedeemed(uint256 id, address buyer, address seller, IERC20 token, uint256 amount, bool isFullyRedeemed);

    constructor() {
        escrowCount = 0;
    }

    /**
     * @dev Deposit tokens into the escrow.
     */
    function depositInEscrow(address seller, IERC20 token, uint256 amount) public {
        // transfer the tokens to the contract
        token.transferFrom(msg.sender, address(this), amount);

        // create the escrow
        Escrow memory escrow = Escrow({
            withdrawableBlockNumber: block.number + ESCROW_DURATION,
            buyer: msg.sender,
            seller: seller,
            token: token,
            amount: amount,
            isFullyRedeemed: false
        });

        // store the escrow
        escrows[escrowCount] = escrow;

        emit EscrowCreated(escrowCount, msg.sender, seller, token, amount);

        // increment escrowCount
        escrowCount += 1;
    }

    /**
     * @dev Withdraw the tokens from the escrow after the escrow duration has passed.
     * @notice This function returns the full amount to the seller if the escrow is not fully redeemed.
     */
    function withdraw(uint256 escrowId) public {
        Escrow storage escrow = escrows[escrowId];

        // check if the escrow is fully redeemed
        require(!escrow.isFullyRedeemed, "Escrow is fully redeemed");

        // check if the withdrawable block number has passed
        require(block.number >= escrow.withdrawableBlockNumber, "Escrow is not yet withdrawable");

        // transfer the tokens to the seller
        escrow.token.transfer(escrow.seller, escrow.amount);

        // mark the escrow as fully redeemed
        escrow.isFullyRedeemed = true;
        emit EscrowRedeemed(escrowId, escrow.buyer, escrow.seller, escrow.token, escrow.amount, escrow.isFullyRedeemed);
    }
}
