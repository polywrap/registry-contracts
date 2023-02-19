// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {PackageRegistry} from "./PackageRegistry.sol";
import {VersionRegistry} from "./VersionRegistry.sol";
import {MerkleTreeManager} from "./MerkleTreeManager.sol";

contract PolywrapRegistry is PackageRegistry, VersionRegistry {
    constructor() VersionRegistry(new MerkleTreeManager(address(this))) {
    }
}
