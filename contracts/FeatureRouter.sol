// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "./TransferHelper.sol";
import "./IFeatureProject.sol";
import "./IWETH.sol";

contract FeatureRouter {

  address public factory;

  address public WETHAddress;

  // only initialize permission
  address public owner;

  constructor() {
    owner = msg.sender;
  }

  function initialize(address _factory, address _WETHAddress) public {
    require(msg.sender == owner, 'o');

    factory = _factory;
    WETHAddress = _WETHAddress;
  }

  function changeOwner(address _owner) public {
    require(msg.sender == owner, 'o');

    owner = _owner;
  }

  function addPair(address _project, address _profiteTo, address _token, uint _amount, bool _IsLeftSide, string calldata memo, string calldata memoUri) public {
    require(_project != address(0), 'Project?');
    TransferHelper.safeTransferFrom(_token, msg.sender, _project, _amount);

    IFeatureProject(_project).addPair(_profiteTo, _token, _amount, _IsLeftSide, memo, memoUri);
  }

  function addPairByEth(address _project, address _profiteTo, bool _IsLeftSide, string calldata memo, string calldata memoUri) public payable {
    require(_project != address(0), 'Project?');
    address _WETHAddress = WETHAddress;
    IWETH(_WETHAddress).deposit{value: msg.value}();

    TransferHelper.safeTransferFrom(_WETHAddress, address(this), _project, msg.value);

    IFeatureProject(_project).addPair(_profiteTo, WETHAddress, msg.value, _IsLeftSide, memo, memoUri);
  }

  function joinPair(address _project, address _profiteTo, uint _appendId, address _token, uint _amount, bool _IsLeftSide, string calldata memo, string calldata memoUri) public {
    TransferHelper.safeTransferFrom(_token, msg.sender, _project, _amount);

    IFeatureProject(_project).joinPair(_appendId, _profiteTo, _token, _amount, _IsLeftSide, memo, memoUri);
  }

  function joinPairByEth(address _project, address _profiteTo, uint _appendId, bool _IsLeftSide, string calldata memo, string calldata memoUri) public payable {
    address _WETHAddress = WETHAddress;
    IWETH(_WETHAddress).deposit{value: msg.value}();

    TransferHelper.safeTransferFrom(_WETHAddress, msg.sender, _project, msg.value);

    IFeatureProject(_project).joinPair(_appendId, _profiteTo, _WETHAddress, msg.value, _IsLeftSide, memo, memoUri);
  }
}
