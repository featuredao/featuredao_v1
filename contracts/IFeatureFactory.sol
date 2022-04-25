// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
interface IFeatureFactory {

  function getProject(uint _id) external view returns (address);

  function lastProjId() external view returns (uint);
}
