pragma solidity 0.8.0;
//SPDX-License-Identifier: MIT

//import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";
//learn more: https://docs.openzeppelin.com/contracts/3.x/erc721

// GET LISTED ON OPENSEA: https://testnets.opensea.io/get-listed/step-two

contract YourCollectible is ERC721URIStorage, VRFConsumerBase{

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  bytes32 internal keyHash;
  uint256 internal fee;
  uint256 public randomResult;

  string[] public assets;

  //this lets you look up a token by the uri (assuming there is only one of each uri for now)
  mapping (string => uint256) public uriToTokenId;

  mapping(bytes32=>uint256) private resultMap;
  mapping(bytes32=>bool) private validIds;

  mapping(bytes32=>address) private requestId2User;
  mapping(address=>uint256) private userRandomNumber;

  /**
       * Constructor inherits VRFConsumerBase
       *
       * Network: kovan
       * Chainlink VRF Coordinator address: 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
       * LINK token address:                0xa36085F69e2889c224210F603D836748e7dC0088
       * Key Hash: 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
       */
  constructor(string[] memory _assets) public ERC721("YourCollectible", "YCB") VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
        ){
//    _setBaseURI("https://ipfs.io/ipfs/");
    for(uint256 i=0;i<_assets.length;i++){
      uriToTokenId[_assets[i]] = type(uint256).max;
      assets[i] = _assets[i];
    }

    keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
    fee = 0.1 * 10 ** 18;
  }

  function mintItem()
      public
      returns (uint256)
  {
      _tokenIds.increment();

      uint256 id = _tokenIds.current();
      _mint(msg.sender, id);

      string memory tokenURI = getFreeTokenUrl(userRandomNumber[msg.sender]);
      _setTokenURI(id, tokenURI);

      uriToTokenId[tokenURI] = id;

      return id;
  }

  function getFreeTokenUrl(uint256 randomNumber) internal view returns (string memory) {
      uint256 loopIndex = randomNumber % assets.length;
      while (uriToTokenId[assets[loopIndex]] != type(uint256).max) {
        loopIndex = loopIndex +  1;
        if ( uriToTokenId[assets[loopIndex]] == type(uint256).max ) {
          break;
        }
        else {
          if (loopIndex >= assets.length) loopIndex = loopIndex % assets.length;
        }
      }
      
      return assets[loopIndex];
  }

  function requestRandomNumber() public returns (bytes32) {
      require(
          LINK.balanceOf(address(this)) >= fee,
          "Not enough LINK - fill contract with faucet"
      );
      bytes32 requestId = requestRandomness(keyHash, fee);
      validIds[requestId] = true;

      //Record user request
      requestId2User[requestId] = msg.sender;
      return requestId;
  }

  function fulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    internal
    override
  {  
      require(validIds[requestId], "id must be not used!") ;
      randomResult = randomness;
      resultMap[requestId]=  randomResult;
      userRandomNumber[requestId2User[requestId]] = randomResult;
      delete validIds[requestId];
  }

  function get()  public view  returns(uint256){
      return randomResult;
  }

  function getById(bytes32 id)  public view  returns(uint256){
      return resultMap[id];
  }

  function checkIdFulfilled(bytes32 id)  public view  returns(bool){
      return validIds[id];
  }

  function getUniformRandomNumber(uint256 _entropy, uint256 _upperBound) public {
    require(_upperBound > 0, "UniformRand/min-bound");
    uint256 min = (type(uint256).max - _upperBound) % _upperBound;
    uint256 random = _entropy;
    while (true) {
      if (random >= min) {
        break;
      }
      random = uint256(keccak256(abi.encodePacked(random)));
    }
    userRandomNumber[msg.sender] = random % _upperBound;
  }

}
