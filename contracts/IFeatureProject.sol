// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IFeatureProject {
  // for factory
  function initialize(uint _lockTime, uint _feeRate, address _judger) external;

  function ensureFeeRateZero() external;
  function rejectJudgerment() external;

  // for router
  function addPair(address _sender, address _token, uint _amount, bool _IsLeftSide, string calldata memo, string calldata memoUri) external;
  function joinPair(uint _appendId, address _sender, address _token, uint _amount, bool _IsLeftSide, string calldata memo, string calldata memoUri) external;
}
