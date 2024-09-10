pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {UntrustedEscrow} from "../src/UntrustedEscrow.sol";
import {TokenWithGod} from "../src/TokenWithGod.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UntrustedEscrowTest is Test {
    UntrustedEscrow public escrow;
    IERC20 public token;
    address public god = address(0x1);
    address public buyer = address(0x2);
    address public seller = address(0x3);

    function setUp() public {
        escrow = new UntrustedEscrow();
        token = new TokenWithGod("TEST", "TST", god);
        token.transfer(buyer, 250_000);
        token.transfer(seller, 750_000);
    }
    
    function test_deposit_and_withdraw_success() public {
        assertEq(token.balanceOf(buyer), 250_000);
        assertEq(token.balanceOf(seller), 750_000);
        assertEq(token.balanceOf(address(escrow)), 0);

        // approve the escrow to transfer tokens
        vm.prank(buyer);
        token.approve(address(escrow), 250_000);

        vm.warp(0);
        vm.prank(buyer);
        uint256 escrowId = escrow.depositInEscrow(seller, token, 250_000);
        assertEq(token.balanceOf(buyer), 0);
        assertEq(token.balanceOf(seller), 750_000);
        assertEq(token.balanceOf(address(escrow)), 250_000);

        // Accelerate time by 3 days
        vm.warp(3 days);
        vm.prank(seller);
        escrow.withdraw(escrowId);
        assertEq(token.balanceOf(buyer), 0);
        assertEq(token.balanceOf(seller), 1_000_000);
        assertEq(token.balanceOf(address(escrow)), 0);
    }

    function test_deposit_and_withdraw_fail_time_not_elapsed() public {
        assertEq(token.balanceOf(buyer), 250_000);
        assertEq(token.balanceOf(seller), 750_000);
        assertEq(token.balanceOf(address(escrow)), 0);

        // approve the escrow to transfer tokens
        vm.prank(buyer);
        token.approve(address(escrow), 250_000);

        vm.warp(0);
        vm.prank(buyer);
        uint256 escrowId = escrow.depositInEscrow(seller, token, 250_000);
        assertEq(token.balanceOf(buyer), 0);
        assertEq(token.balanceOf(seller), 750_000);
        assertEq(token.balanceOf(address(escrow)), 250_000);

        // Accelerate time by 2 days
        vm.warp(2 days);
        vm.prank(seller);
        vm.expectRevert("Escrow is not yet withdrawable");
        escrow.withdraw(escrowId);
        assertEq(token.balanceOf(buyer), 0);
        assertEq(token.balanceOf(seller), 750_000);
        assertEq(token.balanceOf(address(escrow)), 250_000);
    }

    function test_deposit_and_withdraw_fail_already_redeemed() public {
        assertEq(token.balanceOf(buyer), 250_000);
        assertEq(token.balanceOf(seller), 750_000);
        assertEq(token.balanceOf(address(escrow)), 0);

        // approve the escrow to transfer tokens
        vm.prank(buyer);
        token.approve(address(escrow), 250_000);

        vm.warp(0);
        vm.prank(buyer);
        uint256 escrowId = escrow.depositInEscrow(seller, token, 250_000);
        assertEq(token.balanceOf(buyer), 0);
        assertEq(token.balanceOf(seller), 750_000);
        assertEq(token.balanceOf(address(escrow)), 250_000);

        // Accelerate time by 3 days
        vm.warp(3 days);
        vm.prank(seller);
        escrow.withdraw(escrowId);
        assertEq(token.balanceOf(buyer), 0);
        assertEq(token.balanceOf(seller), 1_000_000);
        assertEq(token.balanceOf(address(escrow)), 0);

        // Try to withdraw again
        vm.prank(seller);
        vm.expectRevert("Escrow is fully redeemed");
        escrow.withdraw(escrowId);
        assertEq(token.balanceOf(buyer), 0);
        assertEq(token.balanceOf(seller), 1_000_000);
        assertEq(token.balanceOf(address(escrow)), 0);
    }
}