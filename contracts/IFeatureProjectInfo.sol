// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./AbstractFeatureProjectInfo.sol";

interface IFeatureProjectInfo {
  function initialize(address _factory) external;

  function addProject(
    uint _projId,

    AbstractFeatureProjectInfo.Info calldata _baseInfo,
    AbstractFeatureProjectInfo.Judger calldata _judgerInfo
  ) external;

  function getProjectsById(uint _id) external view returns (AbstractFeatureProjectInfo.Project memory);

}
