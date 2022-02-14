// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Tradable.sol";

/**
 * @title Creature
 * Creature - a contract for my non-fungible creatures.
 */
contract Creature is ERC721Tradable {
    constructor(address _proxyRegistryAddress)
        ERC721Tradable("Creature", "OSC", _proxyRegistryAddress)
    {}

    function baseTokenURI() public pure override returns (string memory) {
        return "http://18.208.216.46/nft/";
    }

    function contractURI() public pure returns (string memory) {
        return "http://18.208.216.46/contract";
    }
}
