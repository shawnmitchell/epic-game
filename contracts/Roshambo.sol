// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";
import "./libraries/Base64.sol";


contract Roshambo is ERC721 {
  // We'll hold our character's attributes in a struct. Feel free to add
  // whatever you'd like as an attribute! (ex. defense, crit chance, etc).
  struct CharacterAttributes {
    uint characterIndex;
    string name;
    string imageURI;        
    uint bankroll;
    uint maxBankroll;
  }

  struct BigBoss {
  string name;
  string imageURI;
  uint bankroll;
  uint maxBankroll;
  }

  BigBoss public bigBoss;

  event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
  event TurnComplete(address sender, uint tokenId, uint newBossBankroll, uint newPlayerBankroll, uint bossPlayed, uint playerPlayed);

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // A lil array to help us hold the default data for our characters.
  // This will be helpful when we mint new characters and need to know
  // things like their HP, AD, etc.
  CharacterAttributes[] defaultCharacters;

  mapping(uint256 => CharacterAttributes) public nftHolderAttributes;
  mapping(address => uint256) public nftHolders;

  // Data passed in to the contract when it's first created initializing the characters.
  // We're going to actually pass these values in from from run.js.
  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterBankroll,
    string memory bossName,
    string memory bossImageURI,
    uint bossBankroll
    
  ) ERC721("Roshambo Legends", "ROSH")
  {
    // Loop through all the characters, and save their values in our contract so
    // we can use them later when we mint our NFTs.
    for(uint i = 0; i < characterNames.length; i += 1) {
      defaultCharacters.push(CharacterAttributes({
        characterIndex: i,
        name: characterNames[i],
        imageURI: characterImageURIs[i],
        bankroll: characterBankroll[i],
        maxBankroll: characterBankroll[i]
      }));

      CharacterAttributes memory c = defaultCharacters[i];
      console.log("Done initializing %s w/ bankroll %s, img %s", c.name, c.bankroll, c.imageURI);
    }
    _tokenIds.increment();

    bigBoss = BigBoss({
      name: bossName,
      imageURI: bossImageURI,
      bankroll: bossBankroll,
      maxBankroll: bossBankroll
    });

  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

    string memory strBankroll = Strings.toString(charAttributes.bankroll);
    string memory strMaxBankroll = Strings.toString(charAttributes.maxBankroll);

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            charAttributes.name,
            ' -- NFT #: ',
            Strings.toString(_tokenId),
            '", "description": "This is an NFT that lets people play in the game Roshambo!", "image": "ipfs://',
            charAttributes.imageURI,
            '", "attributes": [ { "trait_type": "Bankroll", "value": ',strBankroll,', "max_value":',strMaxBankroll,'} ]}'
          )
        )
      )
    );

    string memory output = string(
      abi.encodePacked("data:application/json;base64,", json)
    );
    
    return output;
  }

  function random(string memory input) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input)));
  }

  function getBigBoss() public view returns (BigBoss memory) {
    return bigBoss;
  }

  function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
    return defaultCharacters;
  }

  function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
    // Get the tokenId of the user's character NFT
    uint256 userNftTokenId = nftHolders[msg.sender];
    // If the user has a tokenId in the map, return thier character.
    if (userNftTokenId > 0) {
      return nftHolderAttributes[userNftTokenId];
    }
    // Else, return an empty character.
    else {
      CharacterAttributes memory emptyStruct;
      return emptyStruct;
    }
  }  

  function play(uint value, uint bet, uint seed) public {
    uint nftHolder = nftHolders[msg.sender];
    CharacterAttributes memory _nftHolderAttributes = nftHolderAttributes[nftHolder];
    console.log("Starting - %s: %d", _nftHolderAttributes.name, _nftHolderAttributes.bankroll);
    console.log("Starting - %s: %d", bigBoss.name, bigBoss.bankroll);
    require(bet <= _nftHolderAttributes.bankroll, "you can't bet that much, cowboy!");
    require(bet <= bigBoss.bankroll, "the big boss doesn't have that much!");

    uint256 rand = random(string(abi.encodePacked(Strings.toString(bigBoss.bankroll), Strings.toString(seed), Strings.toString(_nftHolderAttributes.bankroll))));
    uint played = rand % 3;
    console.log("rand: ", rand);
    console.log("played: ", played);
    string memory playerPlay = value == 0 ? "rock" : value == 1 ? "paper" : "scissors";
    string memory bossPlay = played == 0 ? "rock" : played == 1 ? "paper" : "scissors";
    console.log("Player %s played %s. ", _nftHolderAttributes.name, playerPlay);
    console.log("Boss %s played %s", bigBoss.name, bossPlay);

    if (played == value) {
      console.log("push");
    } else if (played == 0 && value == 1) {
      nftHolderAttributes[nftHolder].bankroll += bet;
      bigBoss.bankroll -= bet;
    } else if (played == 0 && value == 2) {
      nftHolderAttributes[nftHolder].bankroll -= bet;
      bigBoss.bankroll += bet;
    } else if (played == 1 && value == 0) {
      nftHolderAttributes[nftHolder].bankroll -= bet;
      bigBoss.bankroll += bet;
    } else if (played == 1 && value == 2) {
      nftHolderAttributes[nftHolder].bankroll += bet;
      bigBoss.bankroll -= bet;
    } else if (played == 2 && value == 0) {
      nftHolderAttributes[nftHolder].bankroll += bet;
      bigBoss.bankroll -= bet;
    } else if (played == 2 && value == 1) {
      nftHolderAttributes[nftHolder].bankroll -= bet;
      bigBoss.bankroll += bet;
    } 

    console.log("Ending - %s: %d", nftHolderAttributes[nftHolder].name, nftHolderAttributes[nftHolder].bankroll);
    console.log("Ending - %s: %d", bigBoss.name, bigBoss.bankroll);
    emit TurnComplete(msg.sender, nftHolder, bigBoss.bankroll, nftHolderAttributes[nftHolder].bankroll, played, value);

  }

  function mintCharacterNFT(uint _characterIndex) external {
    uint256 newItemId = _tokenIds.current();

    _safeMint(msg.sender, newItemId);
    CharacterAttributes memory charAttr = CharacterAttributes({
      characterIndex: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      bankroll: defaultCharacters[_characterIndex].bankroll,
      maxBankroll: defaultCharacters[_characterIndex].bankroll
    });
    nftHolderAttributes[newItemId] = charAttr;
    console.log("Minted NFT tokenId %s and characterIndex %s", newItemId, _characterIndex);
    nftHolders[msg.sender] = newItemId;
    
    _tokenIds.increment();
    emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
  }
}