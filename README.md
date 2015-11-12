# Shapeshift Bot

A simple Ethereum contract to transfer Ether to Bitcoin, via Ether transactions or from within other contracts.

It is using Shapeshift.io for the actual exchange and Oraclize.it from the HTTP communication from within Ethereum.

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

The bot contract currently is currently available at address 0x...

There is also a lookup contract running at 0x... with only one method (getAddress) to retrieve the current address of the bot.

I will periodically publish a new contract based on the changes in this repository and update the lookup contract. Please make a pull request instead of publishing a lot of copies of this contract on Ethereum.
