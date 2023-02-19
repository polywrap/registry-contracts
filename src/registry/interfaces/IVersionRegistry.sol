// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IVersionRegistry {
    //Version requires at least major, minor and patch identifiers specified
    error VersionNotFullLength();
    //Major, minor and patch are release identifiers and they must be numeric (not alphanumeric)
    error ReleaseIdentifierMustBeNumeric();
    error VersionAlreadyPublished();
    //Max count of identifiers is 16
    error TooManyIdentifiers();
    //Identifiers must satisfy [0-9A-Za-z-]+
    error InvalidIdentifier();

    event VersionPublished(bytes32 indexed packageId, bytes32 indexed versionId, bytes versionBytes, string location);

    function publishVersion(bytes32 packageId, bytes memory versionBytes, string memory location)
        external
        returns (bytes32 versionId);
    function versionExists(bytes32 versionId) external view returns (bool);
    function versionLocations(bytes32 versionId) external view returns (string memory location);
}
