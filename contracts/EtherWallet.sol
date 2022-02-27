// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract etherWallet {
    //Creating a state variable for the owner
    //Only the owner will be allowed to withdraw funds from the wallet

    /*
    address: A varibale type, refers to an Ethereum address
    payable: Functions and adresses declared as payable can recieve Either
    public: The varibale is visable to other functions inside and outside of the contract. 
            The Solidity compiler will automatically generate getter functions for public 
            state variables we will be able to see once we complie and deploy the contract in remix
    */

    address payable public owner;

    /* constructor: Called only once time during the life cycle of the contract and that is
                 at the time the contract is deployed onto the block chain
                 Good opprutunity to run any intialization code 
    owner initalization: msg: is a global varibale avaible in a solidity program 
                         msg.sender: Will give us the etherum address or entity of the person who is
                                     deploying the contract 
                                     By default msg.sender is not payable
                        payable: Cast msg.sender to a paybable type to convert it to a paybale type 
                                 in order to set the owner varibale because we declared it as 
                                 payable 
*/
    constructor() {
        owner = payable(msg.sender);
    }

    /* 
    Next set up a function that will allow the contract to send and receive Ether

    receive: Default function that allows the smart contract to receive funds
             As long as there is no parameters or call data sent into the function thats
             sending ether to the contract, receive will be invoked and will allow
             the contract to receive funds 
             Does not require the function keyword
    
    Note: A smart contract can act as a wallet. It's able to receive and hold
          funds like any normal wallet would. You can create a smart contract to 
          act as a savings account or as a wallet like in this case 
    */

    receive() external payable {}

    /*
    Next implement a withdrawal function so the owner can withdraw funds when the owner wants to

    require: In order to make sure that the adrress (msg.sender) that is calling the function is
             the owner.
             Pass in an error message if the check fails 
    
    transfer: A function to transfer funds 

    _amount: A parameter. It is the convention to use an underscore to lable a parameter in solidity

    external: Functions a part of the contracts interface. They can be called from other outside
              contracts and also via transactions, for example by third party applications  

    Notes: There does not need to be a check to ensure that the withdrawal amount is not above
           the balance. The EVM checks that for us. If more funds than avaible is withdrawn, the EVM
           will automatically revert the transaction  

    Notes: Functions in Solidity 

           Syntax: function <function name> (<param type> <param name>) <visibiliy(optional)>
                   <state mutability (optional)> returns <returns typer> {...}
    */

    function withdraw(uint256 _amount) external {
        require(
            msg.sender == owner,
            "Invalid: Only the owner can call this method"
        );
        payable(msg.sender).transfer(_amount);
    }

    /*
    Create a function to query the balance of the smart contract at any given time

    view: The function is read only, it is allowed to read information from the blockchain but
          it cannot change or modify it 
    
    return: denotes the return type 

    uint: unsigned inege, meaning it's value must be a non-negative integer. 
          also an alias for uint256

    address(this): Refers to the address of the current smart contract (etherWallet)

    balance: Gives the balance that this contract holds 
    */

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    //  function getBalanceOwner()  external view returns (uint) {
    //     return address(this).balance;
    // }
}
