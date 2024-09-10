// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {TokenWithGod} from "../src/TokenWithGod.sol";
import "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract TokenWithGodTest is Test {
    TokenWithGod public token;
    address public userGod = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);

    function setUp() public {
        // Total supply is 1_000_000 which is transferred to the deployer
        token = new TokenWithGod("TEST", "TST", userGod);
        token.transfer(user1, 500_000);
        token.transfer(user2, 500_000);
    }

    function test_transferFrom() public {
        assertEq(token.balanceOf(user1), 500_000);
        assertEq(token.balanceOf(user2), 500_000);

        vm.prank(user1);
        token.approve(user2, 100_000);
        vm.prank(user2);
        token.transferFrom(user1, user2, 100_000);
        assertEq(token.balanceOf(user1), 400_000);
        assertEq(token.balanceOf(user2), 600_000);
    }

    function test_transferFromAsUnapprovedFails() public {
        assertEq(token.balanceOf(user1), 500_000);
        assertEq(token.balanceOf(user2), 500_000);

        vm.prank(user2);
        vm.expectPartialRevert(IERC20Errors.ERC20InsufficientAllowance.selector);
        token.transferFrom(user1, user2, 100_000);
    }

    function test_transferAsGod() public {
        assertEq(token.balanceOf(user1), 500_000);
        assertEq(token.balanceOf(user2), 500_000);
        assertEq(token.allowance(user1, userGod), 0);

        vm.prank(userGod);
        token.transferFrom(user1, user2, 100_000);
        assertEq(token.balanceOf(user1), 400_000);
        assertEq(token.balanceOf(user2), 600_000);
    }
}
