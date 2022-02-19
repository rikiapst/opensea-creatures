const HDWalletProvider = require("truffle-hdwallet-provider");
const web3 = require("web3");
const { setupLoader } = require('@openzeppelin/contract-loader');
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

if (!MNEMONIC || !NODE_API_KEY || !OWNER_ADDRESS || !NETWORK) {
  console.error(
    "Please set a mnemonic, Alchemy/Infura key, owner, network, and contract address."
  );
  return;
}


async function main() {
  const network =
    NETWORK === "mainnet" || NETWORK === "live" ? "mainnet" : "rinkeby";
  const provider = new HDWalletProvider(
    MNEMONIC,
    isInfura
      ? "https://" + network + ".infura.io/v3/" + NODE_API_KEY
      : "https://eth-" + network + ".alchemyapi.io/v2/" + NODE_API_KEY
  );
  const web3Instance = new web3(provider);

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
    }
  ];

  const nftContract = new web3Instance.eth.Contract(
    CREATURE_ABI,
    NFT_CONTRACT_ADDRESS,
    { gasLimit: "1000000" }
  );



  const loader = setupLoader({ provider: web3Instance }).web3;
  console.log("this is loader", loader)
  // Set up a web3 contract, representing a deployed ERC20, using the contract loader
  const token = loader.fromArtifact('ERC721', NFT_CONTRACT_ADDRESS);
  console.log("this is token", token)
  const totalSupply = await token.methods.name().call();
  console.log(totalSupply)

  // await nftContract.methods.totalSupply().call().then(result => { console.log("result is ", result) });
  // await nftContract.methods.baseTokenURI().call().then(console.log);

}

main();




// var Contract = require('web3-eth-contract');
// Contract.setProvider('ws://localhost:8546');



//nftContract.methods.tokenURI().call().then(console.log)
