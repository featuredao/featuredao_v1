// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IFeatureProject {
  // for factory
  function initialize(uint _lockTime, uint _feeRate, address _judger) external;

  function ensureFeeRateZero() external;
  function rejectJudgerment() external;

  // for router
  function addPair(address _sender, address _token, uint _amount, bool _IsLeftSide, string calldata memo, string calldata memoUri) external returns (uint);
  function joinPair(uint _appendId, address _sender, address _token, uint _amount, bool _IsLeftSide, string calldata memo, string calldata memoUri) external;

  function isLeftSideWin() external view returns (bool);
  function feeRate() external view returns (uint);
  function judgeFeeRateZeroPending() external view returns (bool);
  function isAnnounced() external view returns (bool);
  function judgmentPending() external view returns (bool);
  function judgmentStartTime() external view returns (uint);
  function lockTime() external view returns (uint);
  function judger() external view returns (address);
  
  function lastPairId() external view returns (uint);
  function leftSide(uint _pairId) external view returns (address);
  function rightSide(uint _pairId) external view returns (address);
  function token(uint _pairId) external view returns (address);
  function amount(uint _pairId) external view returns (uint);
  function status(uint _pairId) external view returns (uint);
  function memoLeftSide(uint _pairId) external view returns (string memory);
  function memoUriLeftSide(uint _pairId) external view returns (string memory);
  function memoRightSide(uint _pairId) external view returns (string memory);
  function memoUriRightSide(uint _pairId) external view returns (string memory);


  
}
