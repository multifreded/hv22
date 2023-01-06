CSS: ../meta/avenir-white.css

[← Day 05](../day05/) / [↑ TOC](../README.md) / [→ Day 07](../day07/)


# Day 06 / HV22.06 privacy isn't given



## Challenge

* Author: HaCk0
* Tags:   `#exploitation`
* Level:  easy

As every good IT person, Santa doesn't have all his backups at one place.
Instead, he spread them all over the world.
With this new blockchain unstoppable technology emerging (except Solana, this
chain stops all the time) he tries to use it as another backup space. To test
the feasibility, he only uploaded one single flag. Fortunately for you, he
doesn't understand how blockchains work.

Can you recover the flag?

--------------------------------------------------------------------------------

**Information**

Start the Docker in the `Resources` section. You will be able to connect to a
newly created Blockchain. Use the following information to interact with the
challenge.

Wallet public key `0x28a8746e75304c0780e011bed21c72cd78cd535e`
Wallet private key
`0xa453611d9419d0e56f499079478fd72c37b251a94bfde4d19872c44cf65386e3`
Contract address: `0xe78A0F7E598Cc8b0Bb87894B0F60dD2a88d6a8Ab`

The source code of the contract is the following block of code:

``` js
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract NotSoPrivate {
    address private owner;
    string private flag;

    constructor(string memory _flag) {
        flag = _flag;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function setFlag(string calldata _flag) external onlyOwner {
        flag = _flag;
    }
}
```

--------------------------------------------------------------------------------

_[Additionally there was the [Blockchain 101][blockchain101]: a short tutorial
on running custom contract code on the private Ethereum-Network with the help of
the Wallet-Tool metamask and a Web-IDE called remix.ethereum.]_

[blockchain101]: Blockchain_101.html



## Solution

_I'm no blockchain-head so take these explanations with a grain of salt._

_Contract_ is just a fancy name for _program that lies on the blockchain_. Data
that is processed with a contract-program also lies on the blockchain.

Although the word _private_ suggests, that the variable's content is access
restricted, it is in fact not. The _private_ modifier is only relevant in a
programming context. It conveys to a human programmer, that the variable is
only relevant within the contract and doesn't matter in other contracts.

Data that is handled by `private` variables gets stored unencrypted on the
blockchain like every other variable does. In others word, the flag simply
lies on the blockchain in plain text.

The only hurdle that needs to be overcome is spelling out the right pieces of
solidity-code in order to read out the flag that was previously written to
the blockchain. (And to deal with the constantly failing blockchain-web-service
`>:-O`. _Sry but it was so frustrating._)

There is a nice blog article -
[How to read "private" variables in contract storage][blogContractStorage] -
that explains all relevant details.

[blogContractStorage]: https://medium.com/coinmonks/how-to-read-private-variables-in-contract-storage-with-truffle-ethernaut-lvl-8-walkthrough-b2382741da9f

The tl;dr is that each contract has 2^256 _slots_ (each 32 bytes) of storage
available. The flag lies in one of those slots, probably one of the first few
slots. It also explains that `Web3.js` - a javascript framework for
interacting with a blockchain - contains a convenient function to access these
slots:

``` js
web3.eth.getStorageAt(contractAddress, slotNumber)
```

The web3 framework is also available for python, so we use that ...

``` sh
pip install web3
python3
> from web3 import Web3
> w3 = Web3(Web3.HTTPProvider('http://152.96.7.6:8545'))
> w3.isConnected()
True
> w3.eth.getStorageAt('0xe78A0F7E598Cc8b0Bb87894B0F60dD2a88d6a8Ab', 0)
HexBytes('0x00000000000000000000000090f8bf6a479f320ead074411a4b0e7944ea8c9c1')
> w3.eth.getStorageAt('0xe78A0F7E598Cc8b0Bb87894B0F60dD2a88d6a8Ab', 1)
HexBytes('0x485632327b436834316e535f6172335f5075626c31437d00000000000000002e')
```

The IP address and the port number stem from the hacking-lab web-service. The
`contractAddress` is from the challenge description and refers to the contract
program on the blockchain. The first slot contained probably the data from the
`owner` variable. The second slot was a direct hit: that is the hex
representation of a flag beginning with `HV22{`.

Converting the following bytes from hex to ASCII gave the flag: \
`485632327b436834316e535f6172335f5075626c31437d`

--------------------------------------------------------------------------------

Flag: `HV22{Ch41nS_ar3_Publ1C}`

[← Day 05](../day05/) / [↑ TOC](../README.md) / [→ Day 07](../day07/)
