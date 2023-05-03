// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ChicBoxNFT is ERC721URIStorage, KeeperCompatibleInterface, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private tokenIdCounter;

    struct TokenDetail {
        uint256 lastLevelUpTimestamp;
        uint256 tokenLevel;
    }

    uint256 private s_upkeepInterval;
    uint256 private s_prevUpkeepTimestamp;
    string [] s_tokenUris = [
        "https://ipfs.io/ipfs/Qmbc64sxTZVmbQbeFBifb99hdAMSCRVW8s1GMQvy6FhWb7?filename=box",
        "https://ipfs.io/ipfs/QmQcor1ZxV8o2pACm4cgPmCvgqtePGgcHaJNp5ZxWGR8Zp?filename=animBox",
        "https://ipfs.io/ipfs/QmT4VK4DmfVe9CbS4BnWUyUbMh8WxyuGVGv3JrhLpbNj98?filename=reward"
    ];
    mapping (uint256 => TokenDetail) private s_tokenDetails;
    uint256 private immutable i_maxUserSupply;
    uint256 private immutable i_nftLevelUpIntervalDays;


    constructor (uint256 _upkeepInterval, uint256 _nftLevelUpIntervalDays, uint256 _maxUserSupply) ERC721 ("POLYdNFTs", "bNFTs") {
        s_upkeepInterval = _upkeepInterval;
        i_nftLevelUpIntervalDays = _nftLevelUpIntervalDays * 1 days;
        s_prevUpkeepTimestamp = block.timestamp;
        i_maxUserSupply = _maxUserSupply;
    }


    function safeMint () public {
        uint256 newId = tokenIdCounter.current();
        tokenIdCounter.increment();

        require (newId < i_maxUserSupply, "dNFT: Max supply limit has been reached.");

        s_tokenDetails[newId].lastLevelUpTimestamp = block.timestamp;
        s_tokenDetails[newId].tokenLevel = 0;

        _setTokenURI(newId, s_tokenUris[0]);

        _safeMint(msg.sender, newId);    
    }


    function devMint () public onlyOwner() {
        uint256 newId = tokenIdCounter.current();
        tokenIdCounter.increment();
        s_tokenDetails[newId].lastLevelUpTimestamp = block.timestamp;
        s_tokenDetails[newId].tokenLevel = 2;

        _setTokenURI(newId, s_tokenUris[2]);

        _safeMint(msg.sender, newId);    
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
        bool intervalPassed = block.timestamp - s_prevUpkeepTimestamp > s_upkeepInterval;
        bool allTokensEvolved = s_tokenDetails[tokenIdCounter.current() - 1].tokenLevel == 2;

        upkeepNeeded = intervalPassed && (!allTokensEvolved);
        return (upkeepNeeded, "0x0");
    }

    function performUpkeep(bytes calldata /* performData */) external override { 
        (bool upkeepNeeded, ) = checkUpkeep("");

        if(upkeepNeeded) {
            for (uint256 i = 0; i < tokenIdCounter.current(); i++) {
                if (block.timestamp - s_tokenDetails[i].lastLevelUpTimestamp > i_nftLevelUpIntervalDays && s_tokenDetails[i].tokenLevel < 2) {
                    s_tokenDetails[i].tokenLevel++;
                    s_tokenDetails[i].lastLevelUpTimestamp = block.timestamp;
                    _setTokenURI(i, s_tokenUris[s_tokenDetails[i].tokenLevel]);
                }
            }
        }
    }



}
