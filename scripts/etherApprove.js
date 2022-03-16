const MNEMONIC = process.env.MNEMONIC;
const ethers = require('ethers');

const alchemyProvider = new ethers.providers.WebSocketProvider('wss://eth-rinkeby.alchemyapi.io/v2/7wWUF2gIYOCCSYjdWTCHZCSYE6MtpXVe');

const wallet = ethers.Wallet.fromMnemonic(MNEMONIC);
const account = wallet.connect(alchemyProvider);

const addresses = {
  WETH: '0xc778417E063141139Fce010982780140Aa0cD5Ab',
  factory: '0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f',
  router: '0x31dFb0F420b24e619f4174E575872559821E2c9B',//contract address
  recipient: '0x1a9Cf6FdEAB2937Fc4f204819e3e963dd197715a',
  me: '0x76e7180a22a771267d3bb1d2125a036ddd8344d9',
}

async function set_allowance_ether(account, token, amount, addresses) {
  const etherAmount = ethers.utils.parseUnits(`${amount}`, 'ether');
  const weth = new ethers.Contract(
    token,
    ['function approve(address _spender, uint256 _value) public returns (bool success)',
      'function allowance(address owner, address spender) external view returns (uint)'],
    account
  );
  const tx = await weth.approve(addresses.router, etherAmount);
  const receipt = await tx.wait();
  console.log(`approval receipt ${receipt}`)
  const amountApproved = await weth.allowance(addresses.recipient, addresses.router);
  console.log(`amount approved ${amountApproved.toString()}`);
  return amountApproved;
}



set_allowance_ether(account, addresses.WETH, 10000000000000000000, addresses);