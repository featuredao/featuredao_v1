// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

abstract contract AbstractFeatureProjectInfo {
  struct Judger {
    string name;
    string description;
    string twitter;
  }

  struct Info {
    string name;
    string logoUri;
    string description;
    string moreInfo;
  }

  struct Project {
    Info baseInfo;
    Judger judgerInfo;
  }

  event ProjectCreated(Project);

  mapping(uint => Project) public projects;

  address factory;
}
