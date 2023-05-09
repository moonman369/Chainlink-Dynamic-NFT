// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ChicToken.sol";

contract ChicBoxNFT is ERC721URIStorage, VRFConsumerBaseV2, KeeperCompatibleInterface, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private tokenIdCounter;

    event RandomWordsRequested (uint256 requestId);

    struct TokenDetail {
        uint256 lastLevelUpTimestamp;
        uint8 tokenLevel;
        bool isDevToken;
    }


    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private s_upkeepInterval;
    uint256 private s_prevUpkeepTimestamp;
    string [] s_tokenUris = [
        "https://cdn.discordapp.com/attachments/1103671253509877840/1105228866542387220/346096668_229284673135880_3096119618190984592_n.jpg",
        "https://cdn.discordapp.com/attachments/1103671253509877840/1105228866827603978/346090674_599131542185455_3227289421851680253_n.jpg",
        "https://cdn.discordapp.com/attachments/1103671253509877840/1105228867184107531/346103687_136134002782123_1062806860937787889_n.jpg",
        "https://cdn.discordapp.com/attachments/1103671253509877840/1105228976668029018/344027704_625169222819599_872616007125247412_n.jpg"
    ];
    mapping (uint256 => TokenDetail) private s_tokenDetails;
    uint256 private immutable i_maxUserSupply;
    uint256 private immutable i_nftLevelUpIntervalDays;
    ChicToken private immutable i_chicToken;


    constructor (
        address _vrfCoordinatorV2,
        uint64 _subscriptionId,
        bytes32 _gasLane, // keyHash
        uint32 _callbackGasLimit,

        uint256 _upkeepInterval,
        uint256 _nftLevelUpIntervalDays, 
        uint256 _maxUserSupply,
        address _chicTokenAddress
    ) ERC721 ("POLYdNFTs", "bNFTs") VRFConsumerBaseV2 (_vrfCoordinatorV2) {

        i_gasLane = _gasLane;
        i_subscriptionId = _subscriptionId;
        i_callbackGasLimit = _callbackGasLimit;
        i_vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorV2);

        s_upkeepInterval = _upkeepInterval;
        i_nftLevelUpIntervalDays = _nftLevelUpIntervalDays * 1 days;
        s_prevUpkeepTimestamp = block.timestamp;
        i_maxUserSupply = _maxUserSupply;
        i_chicToken = ChicToken(_chicTokenAddress);
    }


    function setUpkeepInterval (uint256 _newInterval) public onlyOwner {
        require (_newInterval > 30, "ChicBoxNFT: Upkeep interval cannot be less than 30 seconds");
        s_upkeepInterval = _newInterval;
    }


    function safeMint (address _to) public {
        uint256 newId = tokenIdCounter.current();
        tokenIdCounter.increment();

        require (newId < i_maxUserSupply, "dNFT: Max supply limit has been reached.");
        require (i_chicToken.balanceOf(_to) >= 10 ** i_chicToken.decimals(), "dNFT: User must have atleast 1 CHIC.");

        s_tokenDetails[newId].lastLevelUpTimestamp = block.timestamp;
        s_tokenDetails[newId].tokenLevel = 0;
        s_tokenDetails[newId].isDevToken = false;

        _safeMint(_to, newId); 

        _setTokenURI(newId, s_tokenUris[0]);   
    }


    function devMint (address _to) public onlyOwner() {
        uint256 newId = tokenIdCounter.current();
        tokenIdCounter.increment();
        s_tokenDetails[newId].lastLevelUpTimestamp = block.timestamp;
        s_tokenDetails[newId].tokenLevel = 2;
        s_tokenDetails[newId].isDevToken = true;

        _safeMint(_to, newId);    

        _setTokenURI(newId, s_tokenUris[2]);
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
        bool allTokensEvolved = s_tokenDetails[tokenIdCounter.current() - 1].tokenLevel >= 2;

        upkeepNeeded = intervalPassed && (!allTokensEvolved);
        return (upkeepNeeded, "0x0");
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external override { 
        (bool upkeepNeeded, ) = checkUpkeep("");

        if(upkeepNeeded) {
            uint256 requestId = i_vrfCoordinator.requestRandomWords(
                i_gasLane,
                i_subscriptionId,
                REQUEST_CONFIRMATIONS,
                i_callbackGasLimit,
                NUM_WORDS
            );

            emit RandomWordsRequested(requestId);
        }
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_prevUpkeepTimestamp = block.timestamp;
            uint8 randomIncrement = randomWords[0] % 10 < 7 ? 1 : 2;

            for (uint256 i = 0; i < tokenIdCounter.current(); i++) {
                if (block.timestamp - s_tokenDetails[i].lastLevelUpTimestamp > i_nftLevelUpIntervalDays && s_tokenDetails[i].tokenLevel < 2 && !s_tokenDetails[i].isDevToken) {
                    s_tokenDetails[i].tokenLevel += randomIncrement;
                    s_tokenDetails[i].lastLevelUpTimestamp = block.timestamp;
                    _setTokenURI(i, s_tokenUris[s_tokenDetails[i].tokenLevel]);
                }
            }
    } 


    function getTokenDetails (uint256 _tokenId) public view returns (TokenDetail memory) {
        require (_tokenId >= 0 && _tokenId < tokenIdCounter.current(), "ChicBoxNFT: Token with supplied id doesn't exist.");
        return s_tokenDetails[_tokenId];
    }

    function getTimeLeftTillNextLevelUp (uint256 _tokenId) public view returns (uint256) {
        require (_tokenId >= 0 && _tokenId < tokenIdCounter.current(), "ChicBoxNFT: Token with supplied id doesn't exist.");
        require (s_tokenDetails[_tokenId].tokenLevel < 2, "ChicBoxNFT: Token has already reached max level.");
        return s_tokenDetails[_tokenId].lastLevelUpTimestamp + i_nftLevelUpIntervalDays - block.timestamp;
    }

    function getMaxUserSupply () public view returns (uint256) {
        return i_maxUserSupply;
    }

}
