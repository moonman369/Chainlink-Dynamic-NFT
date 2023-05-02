// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ChicBoxNFT is ERC721URIStorage, KeeperCompatibleInterface, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    uint256 private s_upkeepInterval;

    constructor (uint256 _upkeepInterval) ERC721 ("POLYdNFTs", "bNFTs") {
        s_upkeepInterval = _upkeepInterval;
    }

    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {

    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external override { 
        
    }



}
