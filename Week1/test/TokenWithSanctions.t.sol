// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TokenWithSanctions} from "../src/TokenWithSanctions.sol";

contract TokenWithSanctionsTest is Test {
    TokenWithSanctions public token;
    address public admin = address(0x1);
    address public user = address(0x2);

    function setUp() public {
        // Total supply is 1_000_000 which is transferred to the deployer
        token = new TokenWithSanctions("TEST", "TST", admin);
        token.transfer(user, 500_000);
    }

    function test_banAccount() public {
        assertFalse(token.isBanned(user));
        vm.prank(admin);
        token.banAccount(user);
        assertTrue(token.isBanned(user));
    }

    function test_unbanAccount() public {
        vm.prank(admin);
        token.banAccount(user);
        assertTrue(token.isBanned(user));
        vm.prank(admin);
        token.unbanAccount(user);
        assertFalse(token.isBanned(user));
    }

    function test_onlyAdminCanBan() public {
        vm.prank(user);
        vm.expectRevert("Only admin can ban accounts");
        token.banAccount(user);
    }

    function test_onlyAdminCanUnban() public {
        vm.prank(user);
        vm.expectRevert("Only admin can unban accounts");
        token.unbanAccount(user);
    }

    function test_transfer() public {
        assertEq(token.balanceOf(admin), 0);
        assertEq(token.balanceOf(user), 500_000);

        vm.prank(user);
        token.transfer(admin, 100_000);
        assertEq(token.balanceOf(admin), 100_000);
        assertEq(token.balanceOf(user), 400_000);
    }

    function test_transfer_banned() public {
        assertEq(token.balanceOf(admin), 0);
        assertEq(token.balanceOf(user), 500_000);

        vm.prank(admin);
        token.banAccount(user);
        assertTrue(token.isBanned(user));

        vm.prank(user);
        vm.expectRevert("Banned account");
        token.transfer(admin, 100_000);
    }

    function test_transfer_ban_then_unban() public {
        assertEq(token.balanceOf(admin), 0);
        assertEq(token.balanceOf(user), 500_000);

        vm.prank(admin);
        token.banAccount(user);
        assertTrue(token.isBanned(user));

        vm.prank(admin);
        token.unbanAccount(user);
        assertFalse(token.isBanned(user));

        vm.prank(user);
        token.transfer(admin, 100_000);
        assertEq(token.balanceOf(admin), 100_000);
        assertEq(token.balanceOf(user), 400_000);
    }
}
