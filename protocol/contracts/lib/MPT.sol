// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "./RLPReader.sol";

/*
    Documentation:
    - https://ethereum.org/en/developers/docs/data-structures-and-encoding/patricia-merkle-trie/
    - https://easythereentropy.wordpress.com/2014/06/04/understanding-the-ethereum-trie/
*/
library MPT {
    using RLPReader for RLPReader.RLPItem;
    using RLPReader for RLPReader.Iterator;

    struct MerkleProof {
        bytes32 expectedRoot;
        bytes key;
        bytes[] proof;
        uint256 keyIndex;
        uint256 proofIndex;
        bytes expectedValue;
    }

    function verifyTrieProof(MerkleProof memory data) internal pure returns (bool) {
        bytes memory node = data.proof[data.proofIndex];
        RLPReader.Iterator memory dec = RLPReader.toRlpItem(node).iterator();

        if (data.keyIndex == 0) {
            if(keccak256(node) != data.expectedRoot) {
                return false;
            }
        } else if (node.length < 32) {
            bytes32 root = bytes32(dec.next().toUint());
            if(root != data.expectedRoot){
                return false;
            }
        } else { 
            if(keccak256(node) != data.expectedRoot){
                return false;
            }
        }

        uint256 numberItems = RLPReader.numItems(dec.item);

        // branch
        if (numberItems == 17) {
            return verifyTrieProofBranch(data);
        }
        // leaf / extension
        else if (numberItems == 2) {
            return verifyTrieProofLeafOrExtension(dec, data);
        }

        if (data.expectedValue.length == 0) return true;
        else return false;
    }

    function verifyTrieProofBranch(MerkleProof memory data)
        internal
        pure
        returns (bool)
    {
        bytes memory node = data.proof[data.proofIndex];

        if (data.keyIndex >= data.key.length) {
            bytes memory item = RLPReader
            .toRlpItem(node)
            .toList()[16].toBytes();
            if (keccak256(item) == keccak256(data.expectedValue)) {
                return true;
            }
        } else {
            uint256 index = uint256(uint8(data.key[data.keyIndex]));
            bytes memory _newExpectedRoot = RLPReader
            .toRlpItem(node)
            .toList()[index].toBytes();

            if ((_newExpectedRoot.length != 0)) {
                data.expectedRoot = b2b32(_newExpectedRoot);
                data.keyIndex += 1;
                data.proofIndex += 1;
                return verifyTrieProof(data);
            }
        }

        if (data.expectedValue.length == 0) return true;
        else return false;
    }

    function verifyTrieProofLeafOrExtension(
        RLPReader.Iterator memory dec,
        MerkleProof memory data
    ) internal pure returns (bool) {
        bytes memory nodekey = dec.next().toBytes();
        bytes memory nodevalue = dec.next().toBytes();
        uint256 prefix;
        assembly {
            let first := shr(248, mload(add(nodekey, 32)))
            prefix := shr(4, first)
        }

        if (prefix == 2) {
            // leaf even
            uint256 length = nodekey.length - 1;
            bytes memory actualKey = sliceTransform(nodekey, 1, length, false);
            bytes memory restKey = sliceTransform(
                data.key,
                data.keyIndex,
                length,
                false
            );
            if (keccak256(data.expectedValue) == keccak256(nodevalue)) {
                if (keccak256(actualKey) == keccak256(restKey)) return true;
                if (keccak256(expandKeyEven(actualKey)) == keccak256(restKey))
                    return true;
            }
        } else if (prefix == 3) {
            // leaf odd
            bytes memory actualKey = sliceTransform(
                nodekey,
                0,
                nodekey.length,
                true
            );
            bytes memory restKey = sliceTransform(
                data.key,
                data.keyIndex,
                data.key.length - data.keyIndex,
                false
            );
            if (keccak256(data.expectedValue) == keccak256(nodevalue)) {
                if (keccak256(actualKey) == keccak256(restKey)) return true;
                if (keccak256(expandKeyOdd(actualKey)) == keccak256(restKey))
                    return true;
            }
        } else if (prefix == 0) {
            // extension even
            uint256 extensionLength = nodekey.length ;
            bytes memory shared_nibbles = sliceTransform(
                nodekey,
                1,
                extensionLength - 1,
                false
            );
            bytes memory restKey = sliceTransform(
                data.key,
                data.keyIndex,
                extensionLength,
                false
            );
            if (
                keccak256(shared_nibbles) == keccak256(restKey) ||
                keccak256(expandKeyEven(shared_nibbles)) == keccak256(restKey)
            ) {
                data.expectedRoot = b2b32(nodevalue);
                data.keyIndex += extensionLength;
                data.proofIndex += 1;
                return verifyTrieProof(data);
            }
        } else if (prefix == 1) {
            // extension odd
            uint256 extensionLength = nodekey.length;
            bytes memory shared_nibbles = sliceTransform(
                nodekey,
                0,
                extensionLength,
                true
            );
            bytes memory restKey = sliceTransform(
                data.key,
                data.keyIndex,
                extensionLength,
                false
            );
            if (
                keccak256(shared_nibbles) == keccak256(restKey) ||
                keccak256(expandKeyEven(shared_nibbles)) == keccak256(restKey)
            ) {
                data.expectedRoot = b2b32(nodevalue);
                data.keyIndex += extensionLength;
                data.proofIndex += 1;
                return verifyTrieProof(data);
            }
        } else {
           return false;
        }
        if (data.expectedValue.length == 0) return true;
        else return false;
    }

    function b2b32(bytes memory data) internal pure returns (bytes32 part) {
        assembly {
            part := mload(add(data, 32))
        }
    }

    function sliceTransform(
        bytes memory data,
        uint256 start,
        uint256 length,
        bool removeFirstNibble
    ) internal pure returns (bytes memory) {
        uint256 slots = length / 32;
        uint256 rest = (length % 32) * 8;
        uint256 pos = 32;
        uint256 si = 0;
        uint256 source;
        bytes memory newdata = new bytes(length);
        assembly {
            source := add(start, data)

            if removeFirstNibble {
                mstore(
                    add(newdata, pos),
                    shr(4, shl(4, mload(add(source, pos))))
                )
                si := 1
                pos := add(pos, 32)
            }

            for {
                let i := si
            } lt(i, slots) {
                i := add(i, 1)
            } {
                mstore(add(newdata, pos), mload(add(source, pos)))
                pos := add(pos, 32)
            }
            mstore(
                add(newdata, pos),
                shl(rest, shr(rest, mload(add(source, pos))))
            )
        }
        return newdata;
    }

    function getNibbles(bytes1 b)
        internal
        pure
        returns (bytes1 nibble1, bytes1 nibble2)
    {
        assembly {
            nibble1 := shr(4, b)
            nibble2 := shr(4, shl(4, b))
        }
    }

    function expandKeyEven(bytes memory data)
        internal
        pure
        returns (bytes memory)
    {
        uint256 length = data.length * 2;
        bytes memory expanded = new bytes(length);

        for (uint256 i = 0; i < data.length; i++) {
            (bytes1 nibble1, bytes1 nibble2) = getNibbles(data[i]);
            expanded[i * 2] = nibble1;
            expanded[i * 2 + 1] = nibble2;
        }
        return expanded;
    }

    function expandKeyOdd(bytes memory data)
        internal
        pure
        returns (bytes memory)
    {
        uint256 length = data.length * 2 - 1;
        bytes memory expanded = new bytes(length);
        expanded[0] = data[0];

        for (uint256 i = 1; i < data.length; i++) {
            (bytes1 nibble1, bytes1 nibble2) = getNibbles(data[i]);
            expanded[i * 2 - 1] = nibble1;
            expanded[i * 2] = nibble2;
        }
        return expanded;
    }
}
