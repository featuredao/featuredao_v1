// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./IFeatureProjectInfo.sol";
import "./FeatureProject.sol";
import "./IFeatureProject.sol";

contract FeatureFactory {
  using SafeMath for uint;

  uint public lastProjId;

  bool public paused;

  // only initialize permission
  address public owner;
  address public feeTo;
  address public info;

  // permission to allow proj feeRate to zero.
  // It's good? Yes!
  // Buy this just can act when judger give up him fee.
  // If factory feeController think there is benefit, feeController will allow it.
  // address public feeController;

  // Blockchain is The Dark Forest, always remember it, keep your save.
  // Everyone is evil. **Maybe this account mentioned below is evil too.**
  // Code is law, we dont want to change any rule's design by code.

  // Now show everyone the guys here.
  // We will try to invite important people to join this as multi-signature account.

  // permission to reject proj judgment permission durning judgmentPending when judgment is not fair.
  // If the leftSide or rightSide think it's not fair, Pleast contract judgeController or us ASAP with persuasive reason, we will reject this judgment.
  // After 7 days, proj judger can make judgment again,
  // Before we do this, Community should start a proposal at https://snapshot.org/
  // So every one should follow the rules:
  // - You won fair and square
  // - A word spoken is past recalling
  // And every one should know:
  // - How much you pay him to make those calls
  // address public judgeController;

  // address[] public projects;
  mapping(uint => address) public projects;

  // event ownerChange(address old, address newone);
  // event judgeControllerChange(address old, address newone);

  // event feeToChange(address old, address newone);
  // event feeControllerChange(address old, address newone);

  constructor() {
    owner = msg.sender;
    feeTo = msg.sender;
    // feeController = msg.sender;
    // judgeController = msg.sender;
  }

  function initialize(address _info) external {
    // require(msg.sender == owner, 'F:owner');
    require(msg.sender == owner);

    info = _info;
  }

  function getProject(uint _projId) external view returns (address) {
    return projects[_projId];
  }

  // factory own base func
  function pause(bool _paused) public {
    // require(msg.sender == owner, 'F:owner');
    require(msg.sender == owner);
    paused = _paused;
  }

  function changeOwner(address _owner) public {
    // require(msg.sender == owner, 'F:owner');
    require(msg.sender == owner);

    // emit ownerChange(owner, _owner);
    owner = _owner;
  }

  function changeFeeTo(address _feeTo) public {
    // require(msg.sender == feeTo, 'F:feeTo');
    require(msg.sender == feeTo);

    // emit feeToChange(feeTo, _feeTo);
    feeTo = _feeTo;
  }

  // function changeJudgeController(address _judgeController) public {
  //   require(msg.sender == judgeController, 'F:controller');

  //   // emit judgeControllerChange(judgeController, _judgeController);
  //   judgeController = _judgeController;
  // }

  // function changeFeeController(address _feeController) public {
  //   require(msg.sender == feeController || msg.sender == owner, 'F:controller');

  //   // emit feeControllerChange(feeController, _feeController);
  //   feeController = _feeController;
  // }

  // All send back self token fee will into mint again.
  function withdrawFee(address _token) public {
    TransferHelper.safeTransfer(_token, feeTo, IERC20(_token).balanceOf(address(this)));
  }

  // If some one is donate eth here, we thanks you to donate to us.
  // If you send eth here by mistake, we thanks you to donate to us, So be careful when make any transcation.
  // Same as other token, because we can withdraw it.
  function withdrawEthFee() public {
    TransferHelper.safeTransferETH(feeTo, address(this).balance);
  }

  receive() external payable {
  }
  // inner base func end

  // other function with project.

  // if their some game is started, if you think is hard to hold the security deposit, you can move it into here
  // if you use eth, you can change it into WETH to move into here.
  // This way it's design for Cobie(https://twitter.com/cobie)
  // as he join as judge between Sensei Algod, Do Kwon and GCR for LUNA's price
  // read https://twitter.com/AlgodTrading/status/1503103705939423234, https://twitter.com/cobie/status/1503271489726185472, https://etherscan.io/address/0x4Cbe68d825d21cB4978F56815613eeD06Cf30152#tokentxns for more detail.
  // Will him join our contract, let's waiting for good news.
  function createProj(
    uint _lockTime,
    uint _feeRate,

    AbstractFeatureProjectInfo.Info calldata _projInfo,
    AbstractFeatureProjectInfo.Judger calldata _judgerInfo
  ) public returns (uint _projId, address _project) {
    // require(_lockTime == 0 || _lockTime > block.timestamp, 'F:lockTime_gt');
    require(_lockTime == 0 || _lockTime > block.timestamp);

    // require(paused == false, 'F:paused');
    require(paused == false);

    // begin from 1
    _projId = lastProjId.add(1);

    bytes memory bytecode = type(FeatureProject).creationCode;
    bytes32 salt = keccak256(abi.encodePacked(_projId));
    assembly {
      _project := create2(0, add(bytecode, 32), mload(bytecode), salt)
    }

    lastProjId = _projId;
    projects[_projId] = _project;

    IFeatureProject(_project).initialize(_lockTime, _feeRate, msg.sender);
    IFeatureProjectInfo(info).addProject(
      _projId,
      _project,
      msg.sender,
      _lockTime,
      _feeRate,
      block.number,
      _projInfo,
      _judgerInfo
    );
  }

  // why any method's lock by factory but it looks not need.
  // there is the reason:
  // - take money by factory, not need to approve many time.
  // - any super control need factory, code is law, no one want to lose his money.
  // - factory need to know if the proj isAnnounced, and stop it's mint process.

  function ensureFeeRateZero(address _project) public {
    // require(msg.sender == feeController, 'F:feeController');
    // require(msg.sender == owner, 'F:feeController');
    require(msg.sender == owner);
    IFeatureProject(_project).ensureFeeRateZero();
  }

  function rejectJudgerment(address _project) public {
    // require(msg.sender == judgeController, 'F:judgeController');
    // require(msg.sender == owner, 'F:judgeController');
    require(msg.sender == owner);
    IFeatureProject(_project).rejectJudgerment();
  }
}
