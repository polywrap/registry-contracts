// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MerkleTreeManager {
    event MerkleRootCalculated(bytes32 indexed root, uint256 leafCount);

    event LeafPublished(bytes32 indexed leaf, uint256 leafIndex);

    struct DynamicMerkleTree {
        //Track unpaired leaves and the highest level(root is at the top) to calculate the merkle root on the fly
        uint256 highestTreeLevel;
        mapping(uint256 => bytes32) unpairedTreeLeaves;
    }

    DynamicMerkleTree private tree;

    address public authorizedPublisher;

    uint256 public leafCount;

    constructor(address _authorizedPublisher) {
        authorizedPublisher = _authorizedPublisher;
    }

    function publishLeaf(bytes32 leaf) public {
        assert(msg.sender == authorizedPublisher);

        addLeafToTree(leaf);

        emit LeafPublished(leaf, leafCount);

        leafCount++;
    }

    function addLeafToTree(bytes32 leaf) private {
        //Go through the unpaired tree leaves and pair them with the new leaf
        uint256 currentTreeLevel = 0;
        while (tree.unpairedTreeLeaves[currentTreeLevel] != 0x0) {
            leaf = keccak256(abi.encodePacked(tree.unpairedTreeLeaves[currentTreeLevel], leaf));

            tree.unpairedTreeLeaves[currentTreeLevel] = 0x0;
            currentTreeLevel++;
        }

        //Store the leftover unpaired leaf to be paired later
        tree.unpairedTreeLeaves[currentTreeLevel] = leaf;

        //Track the highest level
        if (currentTreeLevel > tree.highestTreeLevel) {
            tree.highestTreeLevel = currentTreeLevel;
        }
    }

    function calculateMerkleRoot() public view returns (bytes32) {
        bytes32 leaf = 0x0;

        //Go through the unpaired tree leaves and pair them with the "0x0" leaf
        //If there is no unpaired leaf, just propagate the current one upwards
        uint256 currentTreeLevel = 0;
        while (currentTreeLevel <= tree.highestTreeLevel) {
            if (tree.unpairedTreeLeaves[currentTreeLevel] != 0x0) {
                if (leaf == 0x0) {
                    leaf = tree.unpairedTreeLeaves[currentTreeLevel];
                } else {
                    leaf = keccak256(abi.encodePacked(tree.unpairedTreeLeaves[currentTreeLevel], leaf));
                }
            }

            currentTreeLevel++;
        }

        return leaf;
    }
}
