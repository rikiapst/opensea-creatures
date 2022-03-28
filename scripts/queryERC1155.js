const MNEMONIC = process.env.MNEMONIC;
const ethers = require('ethers');

const alchemyProvider = new ethers.providers.WebSocketProvider('wss://eth-rinkeby.alchemyapi.io/v2/7wWUF2gIYOCCSYjdWTCHZCSYE6MtpXVe');

const wallet = ethers.Wallet.fromMnemonic(MNEMONIC);
const account = wallet.connect(alchemyProvider);

const addresses = {
  upgradable: '0x9D8fA3806D92d3D299010114c53Cb3dD2c627279',
  nft: '0x442f2d12f32B96845844162e04bcb4261d589abf'
}


const upgradable = new ethers.Contract(
  addresses.upgradable,
  [
    'function uri(uint256) public view returns (string memory)',
    'function implementation() public view returns (address)'
  ],
  account
);

const nft = new ethers.Contract(
    addresses.nft,
    [
      'function uri(uint256) public view returns (string memory)',
      'function baseTokenURI() public returns (string memory)'
    ],
    account
  );




async function getImplementationAddress(){
    let contractAddress = await upgradable.implementation();
    console.log("the contract address is: ", contractAddress);
}


async function getUriOriginal(id){
    let uri = await upgradable.uri(id);
    console.log("the uri is: ", uri);
}

async function getUri(id){
    let uri = await nft.uri(id);
    console.log("the uri is: ", uri);
}


getUriOriginal(20);


