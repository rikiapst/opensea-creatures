// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Tradable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);   
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Creature
 * Creature - a contract for my non-fungible creatures.
 */
contract Creature is ERC721Tradable, VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;
    LinkTokenInterface LINKTOKEN;
    IERC20 WETH;

    uint64 s_subscriptionId;
    address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;
    address link = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
    bytes32 keyHash =
        0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 2;
    uint32 public nftSold = 0;

    uint256[] public s_randomWords;
    uint256 public s_requestId;
    address s_owner;
    address weth = 0xc778417E063141139Fce010982780140Aa0cD5Ab;

    uint256 public winner; //changed assign
    uint256 public lotterytStart = 0;
    address maintenance = 0x76e7180A22a771267D3bb1d2125A036dDd8344D9;
    address charity;

    bytes32 contractURIVar;
    bytes32 baseTokenURIVar;

    uint32 public lotterySupply;
    event Winner(uint256 _requestId, uint256 _randomWords, uint256 _winner);
    event TransferFrom(address _from, address _to, uint256 _tokenId);

    bool lotteryOpen;

    constructor(address _proxyRegistryAddress, uint64 subscriptionId)
        ERC721Tradable("Creature", "OSC", _proxyRegistryAddress)
        VRFConsumerBaseV2(vrfCoordinator)
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link);
        s_owner = payable(msg.sender);
        s_subscriptionId = subscriptionId;
        WETH = IERC20(weth);
    }

    function wethBalance() public view returns(uint){
       return WETH.balanceOf(s_owner);
    }

    function baseTokenURI() public pure override returns (string memory) {
        return "http://18.208.216.46/nft/";
    }

    function contractURI() public pure returns (string memory) {
        return "http://18.208.216.46/contract";
    }
    
    function setSubId(uint64 subIdArg) public onlyOwner {
        s_subscriptionId = subIdArg;
    }

    function requestRandomWords() public {
        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function mint(uint32 numNfts) public onlyOwner {
         lotterytStart = this.totalSupply();
         nftSold = 0; 
         lotterySupply = numNfts;
         for (uint256 i = 0; i < numNfts; i++){
             this.mintTo(s_owner);
         }
         lotteryOpen = true;
    }


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        ERC721Tradable.transferFrom(from, to, tokenId);

        if (from == s_owner) {
            nftSold++;

             if (lotterySupply - nftSold == 0) {
                 lotteryOpen = false;
                 requestRandomWords();
             }
        }
         emit TransferFrom(from, to, tokenId);
    }


    

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords;    
        pickWinner();
        emit Winner(requestId, randomWords[0], winner);
    }


    function getWinner() public  view returns(uint256)  {
        require(!lotteryOpen, "Lottery is not closed");
        return winner + lotterytStart;
    }

//PROXY ADDRESS 0xf57b2c51ded3a29e6891aba85459d600256cf317

  function setLotteryOpenTrue() public  {
       lotteryOpen = true;
   }

   function setLotteryOpenFalse() public  {
        lotteryOpen = false;
   }

   function getLotteryOpen() public view returns(bool){
       return lotteryOpen;
   }

   function pickWinner() public  {
        winner = (s_randomWords[0] % (nftSold * 2)) + 1;
   }


   function payOut() public  onlyOwner {
        WETH.transferFrom(
            s_owner,
            maintenance,
            this.wethBalance() / 5 
        );

          if(winner <= nftSold){ 
            WETH.transferFrom(
                 s_owner,
                 this.ownerOf(winner + lotterytStart),
                 this.wethBalance()
            );
        } 
        else{
            WETH.transferFrom(
                s_owner,
                maintenance,
                this.wethBalance()
            );
        }
    }
 
}
