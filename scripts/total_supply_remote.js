const HDWalletProvider = require("truffle-hdwallet-provider");
const web3 = require("web3");
const MNEMONIC = process.env.MNEMONIC;
const NODE_API_KEY = process.env.INFURA_KEY || process.env.ALCHEMY_KEY;
const isInfura = !!process.env.INFURA_KEY;
const FACTORY_CONTRACT_ADDRESS = process.env.FACTORY_CONTRACT_ADDRESS;
const NFT_CONTRACT_ADDRESS = process.env.NFT_CONTRACT_ADDRESS;
const OWNER_ADDRESS = process.env.OWNER_ADDRESS;
const NETWORK = process.env.NETWORK;
const NUM_CREATURES = 12;
const NUM_LOOTBOXES = 4;
const DEFAULT_OPTION_ID = 0;
const LOOTBOX_OPTION_ID = 2;

// var Contract = require('web3-eth-contract');
// Contract.setProvider('ws://localhost:8546');

const CREATURE_ABI = [
  {
    constant: false,
    inputs: [
    ],
    name: "totalSupply",
    outputs: [],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    constant: false,
    inputs: [
    ],
    name: "baseTokenURI",
    outputs: [],
    payable: false,
    stateMutability: "nonpayable",
    type: "function",
  },
  // {
  //   constant: false,
  //   inputs: [
  //     {
  //       name: "_tokenId",
  //       type: "uint256",
  //     },
  //   ],
  //   name: "tokenURI",
  //   outputs: [],
  //   payable: false,
  //   stateMutability: "nonpayable",
  //   type: "function",
  // },
];

const provider = new HDWalletProvider(
  MNEMONIC,
  'http://172.27.64.1:7545/'
);
const web3Instance = new web3(provider);

const nftContract = new web3Instance.eth.Contract(
  CREATURE_ABI,
  NFT_CONTRACT_ADDRESS,
  { gasLimit: "1000000" }
);

let x, y
nftContract.methods.totalSupply().call().then(result => { console.log("result is ", result) })
nftContract.methods.baseTokenURI().call().then(result => { y = result; })
//nftContract.methods.tokenURI().call().then(console.log)
console.log("x and y", x, y, typeof (x));