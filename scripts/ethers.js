const MNEMONIC = process.env.MNEMONIC;
const ethers = require('ethers');


const addresses = {
  creature: '0x3D46BbC14F9447227A7E0A62326B9633f0449d04'
}

const alchemyProvider = new ethers.providers.WebSocketProvider('wss://eth-rinkeby.alchemyapi.io/v2/7wWUF2gIYOCCSYjdWTCHZCSYE6MtpXVe');

const wallet = ethers.Wallet.fromMnemonic(MNEMONIC);
const account = wallet.connect(alchemyProvider);

const nft = new ethers.Contract(
  addresses.creature,
  [
    'function totalSupply() public view returns (uint256)',
    'function baseTokenURI() virtual public pure returns (string memory)',
    'function ownerOf(uint256 _tokenId) external view returns (address)',
    "function mint(uint amount) payable"
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