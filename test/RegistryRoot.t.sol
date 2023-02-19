// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {PolywrapRegistry} from "../src/registry/PolywrapRegistry.sol";
import {IPackageRegistry} from "../src/registry/interfaces/IPackageRegistry.sol";
import {IVersionRegistry} from "../src/registry/interfaces/IVersionRegistry.sol";

contract RegistryRootTest is Test {
    PolywrapRegistry private registry;
    bytes32 private organizationId;
    address private organizationOwner;
    address private packageOwner;
    bytes32 private packageId;

    function setUp() public {
        registry = new PolywrapRegistry();

        organizationId = keccak256(abi.encodePacked("testOrganization"));
        organizationOwner = address(0x1);
        packageOwner = address(0x2);
        string memory packageName = "testPackage";
        packageId = keccak256(abi.encodePacked(organizationId, packageName));

        registry.claimOrganization(organizationId, organizationOwner);

        vm.prank(organizationOwner);
        registry.registerPackage(organizationId, packageName, packageOwner);
    }

    function testCanPublishVersion() public {
        bytes memory versionBytes1 = abi.encodePacked("testVersion1");
        bytes memory versionBytes2 = abi.encodePacked("testVersion2");
        bytes memory versionBytes3 = abi.encodePacked("testVersion3");
        string memory location1 = "testLocation1";
        string memory location2 = "testLocation2";
        string memory location3 = "testLocation3";
        bytes32 versionId1 = keccak256(abi.encodePacked(packageId, versionBytes1));
        bytes32 versionId2 = keccak256(abi.encodePacked(packageId, versionBytes2));
        bytes32 versionId3 = keccak256(abi.encodePacked(packageId, versionBytes3));
        bytes32 leaf1 = keccak256(abi.encodePacked(versionId1, location1));
        bytes32 leaf2 = keccak256(abi.encodePacked(versionId2, location2));
        bytes32 leaf3 = keccak256(abi.encodePacked(versionId3, location3));

        vm.prank(packageOwner);
        registry.publishVersion(packageId, versionBytes1, location1);

        assertEq(registry.root(), leaf1);

        vm.prank(packageOwner);
        registry.publishVersion(packageId, versionBytes2, location2);

        assertEq(registry.root(), keccak256(abi.encodePacked(leaf1, leaf2)));

        vm.prank(packageOwner);
        registry.publishVersion(packageId, versionBytes3, location3);

        assertEq(registry.root(), keccak256(abi.encodePacked(keccak256(abi.encodePacked(leaf1, leaf2)), leaf3)));
    }
}
