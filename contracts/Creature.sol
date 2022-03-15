// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Tradable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
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

    uint winner;
    address maintenance = 0x76e7180A22a771267D3bb1d2125A036dDd8344D9;
    address charity;

    uint public lotteryId;
    mapping (uint => address) public lotteryHistory;

    constructor(address _proxyRegistryAddress, uint64 subscriptionId)
        ERC721Tradable("Creature", "OSC", _proxyRegistryAddress)
        VRFConsumerBaseV2(vrfCoordinator)
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        LINKTOKEN = LinkTokenInterface(link);
        s_owner = payable(msg.sender);
        s_subscriptionId = subscriptionId;
        WETH = IERC20(weth);

        lotteryId = 1;
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

    function returnOne() public pure returns (uint8) {
        return 1;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function requestRandomWords() internal {
        // Will revert if subscription is not set and funded.
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

        this.pickWinner();
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        ERC721Tradable.transferFrom(from, to, tokenId);

        if (from == s_owner) {
            nftSold++;

            if (this.totalSupply() - nftSold == 0) {
                requestRandomWords();
            }
        }
    }

    function pickWinner() public payable returns (uint256) {
       winner = (s_randomWords[0] % nftSold + 1000) + 1;
       payOut();
        return winner;
    }

  

    function payOut() internal {      
        WETH.transferFrom(
                 s_owner,
                 maintenance,
                 this.wethBalance() / 5 
            );

        if(winner <= nftSold){
            
            WETH.transferFrom(
                 s_owner,
                 this.ownerOf(winner),
                 this.wethBalance() / 5 * 4
            );
        } else{
            WETH.transferFrom(
                s_owner,
                address(this),
                this.wethBalance() / 5 * 4
            );
        }

        lotteryHistory[lotteryId] = this.ownerOf(winner);
        lotteryId++;
    }
}
