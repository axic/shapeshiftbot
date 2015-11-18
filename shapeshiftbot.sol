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

  function nibbleToChar(uint nibble) internal returns (uint ret) {
    if (nibble > 9)
      return nibble + 87; // nibble + 'a'- 10
    else
      return nibble + 48; // '0'
  }

  // basically this is an int to hexstring function, but limited to 160 bits
  // FIXME: could be much simpler if we have a simple way of converting bytes32 to bytes or string
  function addressToBytes(address _address) internal returns (bytes) {
    uint160 tmp = uint160(_address);

    // 40 bytes of space, but actually uses 64 bytes
    string memory holder = "                                              ";
    bytes memory ret = bytes(holder);

    // NOTE: this is written in an expensive way, as out-of-order array access
    //       is not supported yet, e.g. we cannot go in reverse easily
    //       (or maybe it is a bug: https://github.com/ethereum/solidity/issues/212)
    uint j = 0;
    for (uint i = 0; i < 20; i++) {
      uint _tmp = tmp / (2 ** (8*(19-i))); // shr(tmp, 8*(19-i))
      uint nb1 = (_tmp / 0x10) & 0x0f;     // shr(tmp, 8) & 0x0f
      uint nb2 = _tmp & 0x0f;
      ret[j++] = byte(nibbleToChar(nb1));
      ret[j++] = byte(nibbleToChar(nb2));
    }

    return ret;
  }

  function transfer(string coin, string recipient) returns (bytes32 myid) {
    return transfer(coin, recipient, false);
  }

  function transfer(string coin, string recipient, bool acceptReturn) returns (bytes32 myid) {
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
    // JSON size is 69+61 bytes at most (+1 byte for zero termination)
    string memory part1 = '{"pair":"eth_btc","withdrawal":"                                                                                                   ';
    bytes memory _json = bytes(part1);
    uint i = 32;
    for (uint j = 0; j < _recipient.length; j++)
          _json[i++] = _recipient[j];
    if (acceptReturn) {
      string memory part2 = '","returnAddress":"0x';
      bytes memory _part2 = bytes(part2);
      for (j = 0; j < _part2.length; j++)
        _json[i++] = _part2[j];

      bytes memory _part3 = addressToBytes(msg.sender);
      for (j = 0; j < _part3.length; j++)
        _json[i++] = _part3[j];
    }
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
