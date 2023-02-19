// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IVersionRegistry} from "./interfaces/IVersionRegistry.sol";
import {PackageRegistry} from "./PackageRegistry.sol";

abstract contract VersionRegistry is PackageRegistry, IVersionRegistry {
    mapping(bytes32 => string) public versionLocations;

    constructor() {}

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

        uint8 identifierCnt = uint8(versionBytes[0]);

        if (identifierCnt > 65) {
            revert TooManyIdentifiers();
        }

        emit VersionPublished(packageId, versionId, versionBytes, location);

        return versionId;
    }

    function versionExists(bytes32 versionId) public view virtual override returns (bool) {
        return bytes(versionLocations[versionId]).length != 0;
    }
}
