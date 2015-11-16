contract ShapeshiftBot {
  function transfer(string coin, string recipient) returns (bytes32 myid);
  function transfer(string coin, string recipient, bool acceptReturn) returns (bytes32 myid);
}

contract ShapeshiftBotLookup {
  function getAddress() returns (address _addr);
}

contract usingShapeshift {
  function shapeshiftTransfer(uint value, string coin, string recipient) internal returns (bytes32 myid) {
    ShapeshiftBotLookup lookup = ShapeshiftBotLookup(0x...);
    ShapeshiftBot shapeshift = ShapeshiftBot(lookup.getAddress());
    return shapeshift.transfer.value(value)(coin, recipient);
  }
}
