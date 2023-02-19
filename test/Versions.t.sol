// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {PolywrapRegistry} from "../src/registry/PolywrapRegistry.sol";
import {IPackageRegistry} from "../src/registry/interfaces/IPackageRegistry.sol";
import {IVersionRegistry} from "../src/registry/interfaces/IVersionRegistry.sol";

contract VersionsTest is Test {
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
        bytes memory versionBytes = abi.encodePacked("testVersion");
        string memory location = "testLocation";

        vm.prank(packageOwner);
        registry.publishVersion(packageId, versionBytes, location);
    }

    function testVersionMetadata() public {
        bytes memory versionBytes = abi.encodePacked("testVersion");
        string memory location = "testLocation";
        bytes32 versionId = keccak256(abi.encodePacked(packageId, versionBytes));

        vm.prank(packageOwner);
        registry.publishVersion(packageId, versionBytes, location);

        bool exists = registry.versionExists(versionId);

        assertEq(exists, true);

        string memory _location = registry.versionLocation(versionId);

        assertEq(_location, location);
    }

    function testForbidsNonPackageOwnerToPublishVersion() public {
        bytes memory versionBytes = abi.encodePacked("testVersion");
        string memory location = "testLocation";
        address impostor = address(0x3);    

        vm.prank(impostor);
        vm.expectRevert(IPackageRegistry.OnlyPackageOwner.selector);
        registry.publishVersion(packageId, versionBytes, location);

        vm.prank(organizationOwner);
        vm.expectRevert(IPackageRegistry.OnlyPackageOwner.selector);
        registry.publishVersion(packageId, versionBytes, location);
    }

    function testForbidsChangingPublishedVersion() public {
        bytes memory versionBytes = abi.encodePacked("testVersion");
        string memory location1 = "testLocation1";
        string memory location2 = "testLocation2";

        vm.prank(packageOwner);
        registry.publishVersion(packageId, versionBytes, location1);

        vm.prank(packageOwner);
        vm.expectRevert(IVersionRegistry.VersionAlreadyPublished.selector);
        registry.publishVersion(packageId, versionBytes, location2);
    }
}
