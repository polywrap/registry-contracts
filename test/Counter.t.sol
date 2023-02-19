// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {PolywrapRegistry} from "../src/registry/PolywrapRegistry.sol";

contract RegistryTest is Test {
    
    PolywrapRegistry private registry;

    function setUp() public {
        registry = new PolywrapRegistry();
    }

    function testClaimOrganization() public {
        bytes32 organizationId = keccak256(abi.encodePacked("test"));
        address owner = address(0x1);
        registry.claimOrganization(organizationId, owner);
        (bool exists, address _owner) = registry.organization(organizationId);
        assertEq(exists, true);
        assertEq(_owner, owner);
    }
}
