# Shapeshift Bot

A simple Ethereum contract to transfer Ether to Bitcoin, via Ether transactions or from within other contracts.

It is using [Shapeshift.io](https://shapeshift.io/) for the actual exchange and [Oraclize.it](https://www.oraclize.it) for the HTTP communication from within Ethereum.

## Usage

It is really simple to use within a contract:

```js
import "shapeshiftbot.api.sol"
contract Hello is usingShapeshift {
  function Hello() {
  }

  function test(uint value, string bitcoinAddress) {
    shapeshiftTransfer(value, "btc", bitcoinAddress);
  }
}
```

In order to make this work, you need to put shapeshiftbot.api.sol in the same directory as your contract. The other Solidity sources are not needed from this project.

I will periodically publish a new contract based on the changes in this repository and update the lookup contract. Please make a pull request instead of publishing a lot of copies of this contract on Ethereum.

## Technical

There are three Solidity source files in this repo:

* shapeshiftbot.sol: the actual source code of the shapeshift contract (bot)
* shapeshiftbot.lookup.sol: the contract doing the lookup service
* shapeshiftbot.api.sol: the API interface bit to be included by contracts using this bot

## Deployed contracts

The bot contract currently is currently available at address 0x...

There is also a lookup contract running at 0x... with only one method (getAddress) to retrieve the current address of the bot.

Both are the version tagged as r1 in this repo.

## Plans or todo

See the [github issue tracker](https://github.com/axic/shapeshiftbot/issues/) for a complete list.

#### Support return address for Shapeshift

In case something goes wrong. Initial plan was to reject transaction which fall below the minimum transaction limit set by Shapeshift, but unfortunately that is tied to the exchange rate of Bitcoin.

In order to support this, converting an address (number) to a hex string is needed.

#### Support storing a public record of transactions

Optionally the sender should be able to keep a record of the transaction:
* value in ethers
* sender Ethereum address
* recipient Bitcoin address

## License

    Copyright (C) 2015 Alex Beregszaszi

    Permission is hereby granted, free of charge, to any person obtaining a copy of
    this software and associated documentation files (the "Software"), to deal in
    the Software without restriction, including without limitation the rights to
    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
    the Software, and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
