// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import './AbstractFeatureProjectInfo.sol';
contract FeatureProjectInfo is AbstractFeatureProjectInfo {
  function initialize(address _factory) external  {
    require(factory == address(0), 'init');
    factory = _factory;
  }

  function getProjectsById(uint _id) external view returns (Project memory) {
    return projects[_id];
  }

  function addProject(
    uint _projId,

    Info calldata _baseInfo,
    Judger calldata _judgerInfo
  ) external {
    require(msg.sender == factory, 'F');

    Project memory proj = Project({
      baseInfo: _baseInfo,
      judgerInfo: _judgerInfo
    });

    projects[_projId] = proj;

    emit ProjectCreated(proj);
  }
}
