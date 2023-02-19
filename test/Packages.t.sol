// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {PolywrapRegistry} from "../src/registry/PolywrapRegistry.sol";
import {IPackageRegistry} from "../src/registry/interfaces/IPackageRegistry.sol";

contract PackagesTest is Test {
    PolywrapRegistry private registry;
    bytes32 private organizationId;
    address private organizationOwner;

    function setUp() public {
        registry = new PolywrapRegistry();

        organizationId = keccak256(abi.encodePacked("testOrganization"));
        organizationOwner = address(0x1);

        registry.claimOrganization(organizationId, organizationOwner);
    }

    function testCanRegisterPackage() public {
        string memory packageName = "testPackage";
        address packageOwner = address(0x2);

        vm.prank(organizationOwner);
        registry.registerPackage(organizationId, packageName, packageOwner);
    }

    function testForbidsNonOrganizationOwnerToRegisterPackage() public {
        string memory packageName = "testPackage";
        address packageOwner = address(0x2);
        address impostor = address(0x3);

        vm.prank(impostor);
        vm.expectRevert(IPackageRegistry.OnlyOrganizationOwner.selector);
        registry.registerPackage(organizationId, packageName, packageOwner);
    }

    function testPackageMetadata() public {
        string memory packageName = "testPackage";
        bytes32 packageId = keccak256(abi.encodePacked(organizationId, packageName));
        address packageOwner = address(0x2);

        vm.prank(organizationOwner);
        registry.registerPackage(organizationId, packageName, packageOwner);

        (bool exists, address owner, bytes32 _organizationId) = registry.package(packageId);

        assertEq(exists, true);
        assertEq(owner, packageOwner);
        assertEq(_organizationId, organizationId);

        exists = registry.packageExists(packageId);

        assertEq(exists, true);

        owner = registry.packageOwner(packageId);

        assertEq(owner, packageOwner);

        _organizationId = registry.packageOrganizationId(packageId);

        assertEq(_organizationId, organizationId);
    }

    function testCanTransferPackageOwnership() public {
        string memory packageName = "testPackage";
        bytes32 packageId = keccak256(abi.encodePacked(organizationId, packageName));
        address firstOwner = address(0x2);
        address secondOwner = address(0x3);

        vm.prank(organizationOwner);
        registry.registerPackage(organizationId, packageName, firstOwner);

        vm.prank(firstOwner);
        registry.transferPackageOwnership(packageId, secondOwner);

        address owner = registry.packageOwner(packageId);

        assertEq(owner, secondOwner);
    }

    function testForbidsNonOwnerToTransferOrganizationOwnership() public {
        string memory packageName = "testPackage";
        bytes32 packageId = keccak256(abi.encodePacked(organizationId, packageName));
        address firstOwner = address(0x2);
        address secondOwner = address(0x3);

        vm.prank(organizationOwner);
        registry.registerPackage(organizationId, packageName, firstOwner);

        vm.prank(secondOwner);
        vm.expectRevert(IPackageRegistry.OnlyPackageOwner.selector);
        registry.transferPackageOwnership(packageId, secondOwner);
    }
}
