// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IVersionRegistry} from "./interfaces/IVersionRegistry.sol";
import {PackageRegistry} from "./PackageRegistry.sol";
import {MerkleTreeManager} from "./MerkleTreeManager.sol";

abstract contract VersionRegistry is PackageRegistry, IVersionRegistry {
    mapping(bytes32 => string) public versionLocations;
    MerkleTreeManager public merkleTreeManager;

    constructor(MerkleTreeManager _merkleTreeManager) {
        merkleTreeManager = _merkleTreeManager;
    }

    /**
     * @dev Publish a new version of a package.
     * @param packageId The ID of a package.
     * @param versionBytes The encoded bytes of a version string.
     * @param location The location where the contents of this package version are stored.
     * @return versionId ID of the published version.
     */
    function publishVersion(bytes32 packageId, bytes memory versionBytes, string memory location)
        public
        returns (bytes32 versionId)
    {
        if (msg.sender != packages[packageId].owner) {
            revert OnlyPackageOwner();
        }

        versionId = keccak256(abi.encodePacked(packageId, versionBytes));

        string memory existingLocation = versionLocations[versionId];

        if (bytes(existingLocation).length != 0) {
            revert VersionAlreadyPublished();
        }

        versionLocations[versionId] = location;

        merkleTreeManager.publishLeaf(keccak256(abi.encodePacked(versionId, location)));

        emit VersionPublished(packageId, versionId, versionBytes, location);

        return versionId;
    }

    function versionExists(bytes32 versionId) public view virtual override returns (bool) {
        return bytes(versionLocations[versionId]).length != 0;
    }

    function versionLocation(bytes32 versionId) public view virtual override returns (string memory) {
        return versionLocations[versionId];
    }

    function root() public view virtual override returns (bytes32) {
        return merkleTreeManager.calculateMerkleRoot();
    }
}
