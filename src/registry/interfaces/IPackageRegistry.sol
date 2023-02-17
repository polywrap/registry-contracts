// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IPackageRegistry {
	event OrganizationClaimed(bytes32 indexed organizationId, address indexed owner);
	event OrganizationOwnerChanged(bytes32 indexed organizationId, address indexed previousOwner, address indexed newOwner);
	event PackageRegistered(bytes32 indexed organizationId, bytes32 indexed	packageId, bytes32 indexed packageName,	address packageOwner);
	event PackageOwnerChanged(bytes32 packageId, address indexed previousOwner, address indexed newOwner);

	function transferOrganizationOwnership(bytes32 organizationId, address newOwner) external;
	function registerPackage(bytes32 organizationId, bytes32 packageName, address packageOwner) external;
	function setPackageOwner(bytes32 packageId, address newOwner) external;
	function transferPackageOwnership(bytes32 packageId, address newOwner) external;
  function organizationOwner(bytes32 organizationId) external view returns (address);
	function organizationExists(bytes32 organizationId) external view returns (bool);
	function organization(bytes32 organizationId) external view returns (bool exists, address owner);
  function packageExists(bytes32 packageId) external view returns (bool);
	function packageOwner(bytes32 packageId) external view returns (address);
	function packageOrganizationId(bytes32 packageId) external view returns (bytes32);
	function package(bytes32 packageId) external view returns (bool exists, address owner, bytes32 organizationId);
}
