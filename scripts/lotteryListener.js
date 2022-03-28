const MNEMONIC = process.env.MNEMONIC;
const ethers = require('ethers');

const alchemyProvider = new ethers.providers.WebSocketProvider('wss://eth-rinkeby.alchemyapi.io/v2/7wWUF2gIYOCCSYjdWTCHZCSYE6MtpXVe');

const wallet = ethers.Wallet.fromMnemonic(MNEMONIC);
const account = wallet.connect(alchemyProvider);

const addresses = {
  lottery: '0x28911A9C3E3986cB66dd00EA70e7c58F426E2D47'
}


const nft = new ethers.Contract(
  addresses.lottery,
  [
    'event Winner(uint256 _requestId, uint256 _randomWords, uint256 _winner)',
    'event TransferFrom(address _from, address _to, uint256 _tokenId)',
    'function payOut()'
  ],
  account
);


requestSet = new Set();

nft.on('Winner',
  async function(requestId, randomWord, winner,){
    if(!requestSet.has(requestId)) {
      requestSet.add(requestId);
      console.log(`Winner selected for requestId ${requestId}`);
      console.log(`Winner is ${winner}`);
      console.log(`random word is ${randomWord}`);
      const tx = await nft.payOut();
      console.log("winner has been paid");
      console.log(`transaction #: ${tx}`);
      
    }
  }
)


tokenSet = new Set();
nft.on('TransferFrom',
  function(from, to, tokenId,){
    if(!tokenSet.has(tokenId)) {
      tokenSet.add(tokenId);
      console.log(`Transfer token id:  ${tokenId} from: ${from} to: ${to}`);
    }
  }
)


