// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Tradable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
/**
 * @title Creature
 * Creature - a contract for my non-fungible creatures.
 */
contract Creature is ERC721Tradable, VRFConsumerBaseV2{
    VRFCoordinatorV2Interface COORDINATOR;
    LinkTokenInterface LINKTOKEN;

     uint64 s_subscriptionId;
    address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;
    address link = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
    bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords =  2;
    uint32 public nftSold = 0;

    uint256[] public s_randomWords;
    uint256 public s_requestId;
    address s_owner;
    constructor(address _proxyRegistryAddress, uint64 subscriptionId)
        ERC721Tradable("Creature", "OSC", _proxyRegistryAddress) VRFConsumerBaseV2(vrfCoordinator) 
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
    }

    function baseTokenURI() public pure override returns (string memory) {
        return "http://18.208.216.46/nft/";
    }

    function contractURI() public pure returns (string memory) {
        return "http://18.208.216.46/contract";
    }

    function returnOne() public pure returns(uint8){
        return 1;
    }

    function requestRandomWords() external {
    // Will revert if subscription is not set and funded.
   require(msg.sender == s_owner, "Invalid: only owner");
    s_requestId = COORDINATOR.requestRandomWords(
      keyHash,
      s_subscriptionId,
      requestConfirmations,
      callbackGasLimit,
      numWords
    );
  }
  
  function fulfillRandomWords(
    uint256, /* requestId */
    uint256[] memory randomWords
  ) internal override {
    s_randomWords = randomWords;

    pickWinner();
  }


   function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
     ERC721Tradable.transferFrom(from, to, tokenId);

     if(from == s_owner){
       nftSold++;

       if (this.totalSupply() - nftSold == 0){
         this.requestRandomWords();
       }
     }
   }

    function pickWinner() public view returns(uint256){
      return s_randomWords[0] % nftSold + 1;
    }

}
