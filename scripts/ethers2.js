const MNEMONIC = process.env.MNEMONIC;
const ethers = require('ethers');
const HDWalletProvider = require("truffle-hdwallet-provider");
const NODE_API_KEY = process.env.INFURA_KEY || process.env.ALCHEMY_KEY;
const FACTORY_CONTRACT_ADDRESS = process.env.FACTORY_CONTRACT_ADDRESS;
const NFT_CONTRACT_ADDRESS = process.env.NFT_CONTRACT_ADDRESS;
const OWNER_ADDRESS = process.env.OWNER_ADDRESS;
const NETWORK = process.env.NETWORK;
const NUM_CREATURES = 12;
const DEFAULT_OPTION_ID = 0;

const addresses = {
  creature: '0x3D46BbC14F9447227A7E0A62326B9633f0449d04'
}
const bigGas = ethers.BigNumber.from("1000000")

const overrides = {
  gasLimit: bigGas
};

const alchemyProvider = new ethers.providers.WebSocketProvider('wss://eth-rinkeby.alchemyapi.io/v2/7wWUF2gIYOCCSYjdWTCHZCSYE6MtpXVe');

const wallet = ethers.Wallet.fromMnemonic(MNEMONIC);
const account = wallet.connect(alchemyProvider);

const nft = new ethers.Contract(
  addresses.creature,
  [
    'function totalSupply() public view returns (uint256)',
    'function baseTokenURI() virtual public pure returns (string memory)',
    'function ownerOf(uint256 _tokenId) external view returns (address)',
    'function mint(uint256 _optionId, address _toAddress) public override',
    'function mintTo(address _to) public onlyOwner'
  ],
  account

);


async function getTotalSupply() {
  let supply = await nft.ownerOf(1)
  console.log("supply ", supply.toString())
  let baseTokenURI = await nft.baseTokenURI()
  console.log("URI ", baseTokenURI)
}

getTotalSupply();

if (!MNEMONIC || !NODE_API_KEY || !OWNER_ADDRESS || !NETWORK) {
  console.error(
    "Please set a mnemonic, Alchemy/Infura key, owner, network, and contract address."
  );
  return;
}

async function main() {
  const network =
    NETWORK === "mainnet" || NETWORK === "live" ? "mainnet" : "rinkeby";
  // Creatures issued directly to the owner.
  const mintAddress = "0x76e7180A22a771267D3bb1d2125A036dDd8344D9"
  for (var i = 0; i < NUM_CREATURES; i++) {
    const result = await
      nft.mint(DEFAULT_OPTION_ID, mintAddress, overrides);
    console.log("Minted creature. Transaction: " + result.transactionHash);
  }

  // Creatures issued directly to the owner.
  for (var i = 0; i < NUM_CREATURES; i++) {
    const result = await
      nft.mintTo(OWNER_ADDRESS);
    console.log("Minted creature. Transaction: " + result.transactionHash);
  }
}



main();
