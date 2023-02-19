// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {PolywrapRegistry} from "../src/registry/PolywrapRegistry.sol";

contract OrganizationsTest is Test {
    PolywrapRegistry private registry;

    function setUp() public {
        registry = new PolywrapRegistry();
    }

    function testCanClaimOrganization() public {
        bytes32 organizationId = keccak256(abi.encodePacked("test"));
        address owner = address(0x1);

        registry.claimOrganization(organizationId, owner);

        (bool exists, address _owner) = registry.organization(organizationId);
        
        assertEq(exists, true);
        assertEq(_owner, owner);
    }

    function testOrganizationMetadata() public {
        bytes32 organizationId = keccak256(abi.encodePacked("test"));
        address owner = address(0x1);

        registry.claimOrganization(organizationId, owner);

        (bool exists, address _owner) = registry.organization(organizationId);
        
        assertEq(exists, true);
        assertEq(_owner, owner);

        exists = registry.organizationExists(organizationId);
        
        assertEq(exists, true);

        _owner = registry.organizationOwner(organizationId);
        
        assertEq(_owner, owner);
    }

    function testCanTransferOrganizationOwnership() public {
        bytes32 organizationId = keccak256(abi.encodePacked("test"));
        address firstOwner = address(0x1);    
        address secondOwner = address(0x2);    

        registry.claimOrganization(organizationId, firstOwner);

        vm.prank(firstOwner);
        registry.transferOrganizationOwnership(organizationId, secondOwner);
        
        (, address _owner) = registry.organization(organizationId);
        
        assertEq(_owner, secondOwner);
    }
}
