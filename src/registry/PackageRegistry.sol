// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Ownable} from "openzeppelin/access/Ownable.sol";
import {IPackageRegistry} from "./interfaces/IPackageRegistry.sol";

error OnlyOrganizationOwner();
error OnlyOrganizationController();
error PackageAlreadyExists();
error OnlyPackageOwner();

abstract contract PackageRegistry is Ownable, IPackageRegistry {
    struct Organization {
        bool exists;
        address owner;
    }

    struct Package {
        bool exists;
        address owner;
        bytes32 organizationId;
    }

    mapping(bytes32 => Organization) organizations;
    mapping(bytes32 => Package) packages;

    function claimOrganization(bytes32 _organizationId, address _owner) public {
        if (!organizations[_organizationId].exists) {
            organizations[_organizationId].exists = true;
        }

        address previousOwner = organizations[_organizationId].owner;
        organizations[_organizationId].owner = _owner;

        emit OrganizationOwnerChanged(_organizationId, previousOwner, _owner);
    }

    function transferOrganizationOwnership(bytes32 _organizationId, address _newOwner)
        public
        virtual
        override
        onlyOrganizationOwner(_organizationId)
    {
        address previousOwner = organizations[_organizationId].owner;
        organizations[_organizationId].owner = _newOwner;

        emit OrganizationOwnerChanged(_organizationId, previousOwner, _newOwner);
    }

    function registerPackage(bytes32 _organizationId, bytes32 _packageName, address _packageOwner)
        public
        virtual
        override
        onlyOrganizationOwner(_organizationId)
    {
        bytes32 packageId = keccak256(abi.encodePacked(_organizationId, _packageName));

        if (packages[packageId].exists) {
            revert PackageAlreadyExists();
        }

        packages[packageId].exists = true;
        packages[packageId].organizationId = _organizationId;

        emit PackageRegistered(_organizationId, packageId, _packageName, _packageOwner);

        _setPackageOwner(packageId, _packageOwner);
    }

    function setPackageOwner(bytes32 _packageId, address _newOwner)
        public
        virtual
        override
        onlyOrganizationOwner(packages[_packageId].organizationId)
    {
        _setPackageOwner(_packageId, _newOwner);
    }

    function transferPackageOwnership(bytes32 _packageId, address _newOwner)
        public
        virtual
        override
        onlyPackageOwner(_packageId)
    {
        _setPackageOwner(_packageId, _newOwner);
    }

    function _setPackageOwner(bytes32 _packageId, address _newOwner) private {
        address previousOwner = packages[_packageId].owner;
        packages[_packageId].owner = _newOwner;

        emit PackageOwnerChanged(_packageId, previousOwner, _newOwner);
    }

    function organizationOwner(bytes32 _organizationId) public view virtual override returns (address) {
        return organizations[_organizationId].owner;
    }

    function organizationExists(bytes32 _organizationId) public view virtual override returns (bool) {
        return organizations[_organizationId].exists;
    }

    function organization(bytes32 _organizationId) public view virtual override returns (bool exists, address owner) {
        Organization memory organizationInfo = organizations[_organizationId];

        return (organizationInfo.exists, organizationInfo.owner);
    }

    function packageExists(bytes32 _packageId) public view virtual override returns (bool) {
        return packages[_packageId].exists;
    }

    function packageOwner(bytes32 _packageId) public view virtual override returns (address) {
        return packages[_packageId].owner;
    }

    function packageOrganizationId(bytes32 _packageId) public view virtual override returns (bytes32) {
        return packages[_packageId].organizationId;
    }

    function package(bytes32 _packageId)
        public
        view
        virtual
        override
        returns (bool exists, address owner, bytes32 organizationId)
    {
        return (packages[_packageId].exists, packages[_packageId].owner, packages[_packageId].organizationId);
    }

    modifier onlyOrganizationOwner(bytes32 _organizationId) {
        if (msg.sender != organizations[_organizationId].owner) {
            revert OnlyOrganizationOwner();
        }
        _;
    }

    modifier onlyPackageOwner(bytes32 _packageId) {
        if (msg.sender != packages[_packageId].owner) {
            revert OnlyPackageOwner();
        }
        _;
    }
}
