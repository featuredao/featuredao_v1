// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "./TransferHelper.sol";
import "./IFeatureProject.sol";

contract FeatureRouter {

  address public factory;

  address public WETHAddress;

  // only initialize permission
  address public owner;

  constructor() {
    owner = msg.sender;
  }

  function initialize(address _factory, address _WETHAddress) public {
    require(msg.sender == owner, 'F:owner');

    factory = _factory;
    WETHAddress = _WETHAddress;
  }

  function changeOwner(address _owner) public {
    require(msg.sender == owner, 'F:owner');

    owner = _owner;
  }

  function addPair(address _project, address _profiteTo, address _token, uint _amount, bool _IsLeftSide, string calldata memo, string calldata memoUri) public {
    require(_project != address(0), 'F:Project?');
    TransferHelper.safeTransferFrom(_token, msg.sender, _project, _amount);

    IFeatureProject(_project).addPair(_profiteTo, _token, _amount, _IsLeftSide, memo, memoUri);
  }

  function joinPair(address _project, address _profiteTo, uint _appendId, address _token, uint _amount, bool _IsLeftSide, string calldata memo, string calldata memoUri) public {
    TransferHelper.safeTransferFrom(_token, msg.sender, _project, _amount);

    IFeatureProject(_project).joinPair(_appendId, _profiteTo, _token, _amount, _IsLeftSide, memo, memoUri);
  }
}
