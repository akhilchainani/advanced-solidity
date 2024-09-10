// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {TokenWithBondingCurve} from "../src/TokenWithBondingCurve.sol";

contract TokenWithBondingCurveTest is Test {
    TokenWithBondingCurve public token;
    address public user1 = address(0x1);
    address public user2 = address(0x2);

    function setUp() public {
        token = new TokenWithBondingCurve("TEST", "TST");
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }

    function test_buy_non_payable() public {
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 0);

        vm.roll(5);
        vm.prank(user1);
        token.buy{value: 1_000 gwei}(1);
        assertEq(token.balanceOf(user1), 1);
        assertEq(token.balanceOf(user2), 0);
    }

    function test_buy_payable() public {
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 0);

        vm.roll(5);
        vm.prank(user1);
        token.buy{value: 1_000 gwei}(2);
        assertEq(token.balanceOf(user1), 2);
        assertEq(token.balanceOf(user2), 0);
        assertEq(user1.balance, 10 ether - 1_000 gwei);
    }

    function test_buy_payable_larger() public {
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 0);

        vm.roll(5);
        vm.prank(user1);
        token.buy{value: 10_000 gwei}(5);
        assertEq(token.balanceOf(user1), 5);
        assertEq(token.balanceOf(user2), 0);
        assertEq(user1.balance, 10 ether - 10_000 gwei);
    }

    function test_buy_and_sell() public {
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 0);

        // User1 buys 2 tokens
        vm.roll(5);
        vm.prank(user1);
        token.buy{value: 1_000 gwei}(2);
        assertEq(token.balanceOf(user1), 2);
        assertEq(token.balanceOf(user2), 0);
        assertEq(user1.balance, 10 ether - 1_000 gwei);

        // User1 buys 2 more tokens at a higher price
        vm.prank(user2);
        token.buy{value: 5_000 gwei}(2);
        assertEq(token.balanceOf(user1), 2);
        assertEq(token.balanceOf(user2), 2);
        assertEq(user2.balance, 10 ether - 5_000 gwei);

        // User1 sells 2 tokens
        vm.roll(10);
        vm.prank(user1);
        token.sell(2);
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 2);
        assertEq(user1.balance, 10 ether - 1_000 gwei + 5_000 gwei);

        // User2 sells 2 tokens
        vm.roll(15);
        vm.prank(user2);
        token.sell(2);
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(user2), 0);
        assertEq(user2.balance, 10 ether - 5_000 gwei + 1_000 gwei);
    }
}
