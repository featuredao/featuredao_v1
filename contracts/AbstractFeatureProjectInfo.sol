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

  struct Projects {
    uint projId;
    address project;
    address judger;

    uint lockTime;

    uint feeRate;
    uint createBlockNumber;

    Info projInfo;
    Judger judgerInfo;
  }

  event ProjectCreated(Projects);

  Projects[] public projects;
  address factory;
}
