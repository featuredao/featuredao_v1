// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
// pragma experimental ABIEncoderV2;

import "./IFeatureProjectInfo.sol";
import "./FeatureProject.sol";
import "./IFeatureProject.sol";
import "./IFeatureFactory.sol";

interface IERC20READRE {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint);
}

contract FeatureReader {
  using SafeMath for uint;
  
  address public owner;
  address public factory;
  address public info;

  struct Project {
    uint projId;
    address project;
    uint lockTime;
    address judger;
    uint lastPairId;
    bool isLeftSideWin;
    bool judgeFeeRateZeroPending;
    bool isAnnounced;
    bool judgmentPending;
    uint feeRate;
    uint judgmentStartTime;
    AbstractFeatureProjectInfo.Info baseInfo;
    AbstractFeatureProjectInfo.Judger judgerInfo;
  }

  struct Pair {
    uint pairId;
    address leftSide;
    address rightSide;
    address token;
    uint amount;
    uint status;

    string memoLeftSide;
    string memoUriLeftSide;
    string memoRightSide;
    string memoUriRightSide;
  }
  
  constructor() {
    owner = msg.sender;
  }


  function initialize(address _factory, address _info) public {
    require(msg.sender == owner, 'owner');

    factory = _factory;
    info = _info;
  }

  function tokenDetail(address _token) public view returns (
    string memory name,
    string memory symbol,
    uint decimals
  ) {
    IERC20READRE token = IERC20READRE(_token);

    name = token.name();  
    symbol = token.symbol();
    decimals = token.decimals();
  }

  function projectList() public view returns (Project[] memory) {
    uint lastProjId = IFeatureFactory(factory).lastProjId();

    Project[] memory projects = new Project[](lastProjId);

    uint _projId = 1;

    for (; _projId <= lastProjId;) {
      Project memory _project = projectDetailBase(_projId);

      projects[_projId - 1] = _project;

      _projId = _projId.add(1);
    }

    return projects;
  }

  function projectDetail(uint _index) public view returns (
    Pair[] memory pairs,
    Project memory projectBase
  ) {
    pairs = projectDetailPairs(_index);
    projectBase = projectDetailBase(_index);
  }

  function projectDetailBase(uint _projId) public view returns (
    Project memory
  ) {
    address _projectAddress = IFeatureFactory(factory).getProject(_projId);
    AbstractFeatureProjectInfo.Project memory _projectInfo = IFeatureProjectInfo(info).getProjectsById(_projId);
    IFeatureProject IProject = IFeatureProject(_projectAddress);

    Project memory _project = Project({
      project: _projectAddress,
      lockTime: IProject.lockTime(),
      judger: IProject.judger(),
      lastPairId: IProject.lastPairId(),
      isLeftSideWin: IProject.isLeftSideWin(),
      judgeFeeRateZeroPending: IProject.judgeFeeRateZeroPending(),
      isAnnounced: IProject.isAnnounced(),
      judgmentPending: IProject.judgmentPending(),
      feeRate: IProject.feeRate(),
      judgmentStartTime: IProject.judgmentStartTime(),
      baseInfo: _projectInfo.baseInfo,
      judgerInfo: _projectInfo.judgerInfo,
      projId: _projId
    });

    return _project;
  }

  function projectDetailPairs(uint _projId) public view returns (
    Pair[] memory
  ) {
    address _projectAddress = IFeatureFactory(factory).getProject(_projId);

    IFeatureProject IProject = IFeatureProject(_projectAddress);

    uint lastPairId = IProject.lastPairId();
    Pair[] memory pairs = new Pair[](lastPairId);
    uint _pairId = 1;
    
    for (; _pairId <= lastPairId;) {
      Pair memory _pair = Pair({
        pairId: _pairId,
        leftSide: IProject.leftSide(_pairId),
        rightSide: IProject.rightSide(_pairId),
        token: IProject.token(_pairId),
        amount: IProject.amount(_pairId),
        status: IProject.status(_pairId),
        memoLeftSide: IProject.memoLeftSide(_pairId),
        memoUriLeftSide: IProject.memoUriLeftSide(_pairId),
        memoRightSide: IProject.memoRightSide(_pairId),
        memoUriRightSide: IProject.memoUriRightSide(_pairId)
      });

      pairs[_pairId - 1] = _pair;

      _pairId = _pairId.add(1);
    }

    return pairs;
  }
}
