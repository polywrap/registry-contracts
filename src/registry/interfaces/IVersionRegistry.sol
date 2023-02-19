// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IVersionRegistry {
    event VersionPublished(bytes32 indexed packageId, bytes32 indexed versionId, bytes versionBytes, string location);

    function publishVersion(bytes32 packageId, bytes memory versionBytes, string memory location)
        external
        returns (bytes32 versionId);
    function versionExists(bytes32 versionId) external view returns (bool);
    function versionLocations(bytes32 versionId) external view returns (string memory location);
}
