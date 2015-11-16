//
// ShapeshiftBot
// A simple contract to programmatically send ethers (converted to bitcoins) to a bitcoin address
//
// (c) 2015 Alex Beregszaszi
//
// Uses the following software:
// - Shapeshift.io for conversion
// - Oraclize.it for HTTP POST support (Thanks Thomas!)
//
// License: MIT
//

import "dev.oraclize.it/api.sol";

contract ShapeshiftBot is usingOraclize {
  mapping (bytes32 => uint) public txns;

  address owner;
  modifier owneronly { if (msg.sender == owner) _ }
  function setOwner(address _owner) owneronly {
    owner = _owner;
  }

  function ShapeshiftBot() {
    owner = msg.sender;
  }

  // Oraclize callback
  function __callback(bytes32 myid, string result) {
    if (msg.sender != oraclize_cbAddress()) throw;

    // parse bitcoin address (code snippet from Oraclize.it)
    address shapeshift = parseAddr(result);

    // grab the actual transaction value
    uint value = txns[myid];
    delete txns[myid];

    shapeshift.send(value);
  }

  function transfer(string coin, string recipient) returns (bytes32 myid) {
    bytes memory _coin = bytes(coin);
    bytes memory _recipient = bytes(recipient);

    // Only accept etherium to bitcoin so far (e.g. check for the string 'btc')
    if ((_coin[0] != 98) || (_coin[1] != 116) || (_coin[2] != 99)) {
      msg.sender.send(msg.value);
      return;
    }

    // Invalid bitcoin address length
    // FIXME: maybe check for the first character too?
    if (_recipient.length < 26 || _recipient.length > 35) {
      msg.sender.send(msg.value);
      return;
    }

    // Reject if below the minimum Shapeshift limit
    // FIXME: this depends on the Bitcoin mining fees, so not a good long-term limit
    if (msg.value < 75 finney) {
      msg.sender.send(msg.value);
      return;
    }

    // FIXME: all this because strings have pretty early support for in Solidity
    // FIXME: include a return address
    // Let’s build up the JSON for Shapeshift:{"pair":"eth_btc","withdrawal":"1MCwBbhNGp5hRm5rC1Aims2YFRe2SXPYKt"}
    // JSON size is 69 bytes at most (+1 byte for zero termination)
    string memory part1 = '{"pair":"eth_btc","withdrawal":"                                      ';
    bytes memory _json = bytes(part1);
    uint i = 32;
    for (uint j = 0; j < _recipient.length; j++)
          _json[i++] = _recipient[j];
    _json[i++] = 34;  // "
    _json[i++] = 125; // }
    // zero out the rest
    for (; i < _json.length;)
        _json[i++] = 0;
    string memory json = string(_json);

    bytes32 id = oraclize_query("URL", "json(https://shapeshift.io/shift).deposit", json);

    // adjust with Oraclize fees
    // FIXME: charge for the transaction at some point
    txns[id] = msg.value - oraclize.getPrice("URL");

    return id;
  }

  function kill() owneronly {
    suicide(msg.sender);
  }
}
