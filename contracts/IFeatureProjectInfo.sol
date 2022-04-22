// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./AbstractFeatureProjectInfo.sol";

interface IFeatureProjectInfo {
  function initialize(address _factory) external;

  function addProject(
    uint _projId,
    address _project,
    address _judger,
    uint _lockTime,
    uint _feeRate,
    uint _createBlockNumber,

    AbstractFeatureProjectInfo.Info calldata _projInfo,
    AbstractFeatureProjectInfo.Judger calldata _judgerInfo
  ) external;
}
