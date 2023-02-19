// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {PackageRegistry} from "./PackageRegistry.sol";
import {VersionRegistry} from "./VersionRegistry.sol";

contract PolywrapRegistry is PackageRegistry, VersionRegistry {}
