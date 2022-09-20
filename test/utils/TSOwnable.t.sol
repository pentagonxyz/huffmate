// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";

interface TSOwnable {
    function owner() external view returns (address);
    function pendingOwner() external view returns (address);
    function setPendingOwner(address) external;
    function acceptOwnership() external;
}

contract TSOwnableTest is Test {
    TSOwnable tsOwnable;
    address immutable huffConfig = 0x18669eb6c7dFc21dCdb787fEb4B3F1eBb3172400;

    function setUp() public {
        // Deploy TSOwnable
        string memory wrapper_code = vm.readFile("test/utils/mocks/TSOwnableWrappers.huff");
        tsOwnable = TSOwnable(
            HuffDeployer
                .config()
                .with_code(wrapper_code)
                .deploy("utils/TSOwnable")
        );
    }

    function testTsOwnableGetOwner() public {
        assertEq(tsOwnable.owner(), huffConfig);
    }

    function testTsOwnableSetPendingOwner() public {
        vm.prank(huffConfig);
        tsOwnable.setPendingOwner(address(0xBEEF));

        assertEq(tsOwnable.pendingOwner(), address(0xBEEF));
    }

    function testTsOwnableSetAndAcceptOwner() public {
        vm.prank(huffConfig);
        tsOwnable.setPendingOwner(address(0xBEEF));
        assertEq(tsOwnable.pendingOwner(), address(0xBEEF));

        vm.prank(address(0xBEEF));
        tsOwnable.acceptOwnership();
        assertEq(tsOwnable.owner(), address(0xBEEF));
        assertEq(tsOwnable.pendingOwner(), address(0));

        vm.startPrank(address(0xBEEF));
        vm.expectRevert("ALREADY_OWNER");
        tsOwnable.setPendingOwner(address(0xBEEF));
        vm.stopPrank();

    }
}