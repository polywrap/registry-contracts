// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import {IVersionRegistry} from "./interfaces/IVersionRegistry.sol";
import {PackageRegistry} from "./PackageRegistry.sol";

//Version requires at least major, minor and patch identifiers specified
error VersionNotFullLength();
//Major, minor and patch are release identifiers and they must be numeric (not alphanumeric)
error ReleaseIdentifierMustBeNumeric();
error VersionAlreadyPublished();
//Max count of identifiers is 16
error TooManyIdentifiers();
//Identifiers must satisfy [0-9A-Za-z-]+
error InvalidIdentifier();

abstract contract VersionRegistry is PackageRegistry, IVersionRegistry {
  mapping(bytes32 => string) public versionLocations;

  constructor() {
    initialize();
  }

  function initialize() public initializer {
    __Ownable_init();
  }

  /**
   * @dev Publish a new version of a package.
   * @param packageId The ID of a package.
   * @param versionBytes The encoded bytes of a version string.
   * @param location The location where the contents of this package version are stored.
   * @return ID of the published version.
   */
  function publishVersion(
    bytes32 packageId,
    bytes memory versionBytes,
    string memory location
  ) public returns (bytes32 versionId) {
    if(msg.sender != packages[packageId].owner) {
			revert OnlyPackageOwner();
		}

    bytes32 versionId = keccak256(abi.encodePacked(packageId, versionBytes));

    string memory existingLocation = versionLocations[versionId];
    
    if(bytes(existingLocation).length != 0) {
      revert VersionAlreadyPublished();
    }

    uint8 identifierCnt = uint8(versionBytes[0]);

    if(identifierCnt > 65) {
      revert TooManyIdentifiers();
    }

    emit VersionPublished(
      packageId,
      versionId,
      versionBytes,
      location
    );

    return versionId;
  }

  function versionExists(bytes32 versionId) public virtual override view returns (bool) {
    return bytes(versionLocations[versionId]).length;
  }
}
