contract ShapeshiftBotLookup {
  address owner;
  address shapeshift;

  modifier owneronly { if (msg.sender == owner) _ }

  function setOwner(address _owner) owneronly {
      owner = _owner;
  }

  function ShapeshiftBotLookup() {
    owner = msg.sender;
  }

  function setAddress(address _addr) owneronly {
    shapeshift = _addr;
  }

  function getAddress() returns (address _addr) {
    return shapeshift;
  }

  function kill() owneronly {
    suicide(msg.sender);
  }
}
