// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./TransferHelper.sol";

contract FeatureProject {
  using SafeMath for uint;

  bool public isLeftSideWin;
  bool public isAnnounced;
  uint public announcedTime;

  // amount * feeRate / 10000 is the fee to judger;
  // amount * feeRate / 10000 is the fee to factory;
  // feeRate lowest is 30;
  // like that: if amount is $1m, if you win, feeRate = 30, judger can get $1000 fee, and factory get $1000 fee, you get $1m and other ($1m - $1000 - $1000) .
  // Lowest then juicebox now 500/10000 a lot.
  // Equal swap 30/10000.
  // cant change to other but 0;
  uint public feeRate;
  // need to set rate to zero, when it's ensure by factory owner. it can't reverse.
  bool public judgeFeeRateZeroPending;

  // factory, contains main auth.
  address public factory;
  // make judgement user.
  address public judger;

  // if is 0. it donn lock.
  // if is not 0, need lockTime >= block.timestamp to make judgement.
  // set when create.
  uint public lockTime;

  // judgment pending
  // when judgmentStartTime is set, it means judgment should start.
  // and will not allow to add or join pair.
  uint public judgmentStartTime;
  bool public judgmentPending;

  // amount of token.
  // reverse will not update when is announced.
  // is no useful after announced.
  mapping(address => uint) public reserve;

  address[] public leftSide;
  address[] public rightSide;

  uint constant statusDefault = 0;
  uint constant statusAbort = 1;
  uint constant statusWithdrawed = 2;
  // status default is 0, 1 is abort, 2 is withdrawed.
  uint[] public status;

  uint[] public amount;
  address[] public token;
  string[] public memoRightSide;
  string[] public memoUriRightSide;
  string[] public memoLeftSide;
  string[] public memoUriLeftSide;

  modifier lockNotAnnounced() {
    // require(isAnnounced == false, 'F:Announced');
    require(isAnnounced == false);
    _;
  }

  constructor() {
    factory = msg.sender;
  }

  // only can initialize one time
  // lock by factory, because it will call just after created.
  function initialize(uint _lockTime, uint _feeRate, address _judger) external {
    // require(msg.sender == factory, 'F:Factory');
    require(msg.sender == factory);

    // only can initialize one time check,
    // when judger is set, it means Initializeed.
    // require(judger == address(0), 'F:init');
    require(judger == address(0));

    // make sure args valid
    // require(_lockTime == 0 || _lockTime > block.timestamp, 'F:lockTime');
    require(_lockTime == 0 || _lockTime > block.timestamp);
    // require(_feeRate >= 30 && _feeRate <= 2000, 'F:FeeRate');
    require(_feeRate >= 30 && _feeRate <= 2000);
    // require(_judger != address(0), 'F:Judger');

    judger = _judger;
    feeRate = _feeRate;
    lockTime = _lockTime;
  }

  // judger can change feeRate to zero
  function unsetFeeRate() external {
    // require(judger == msg.sender, 'F:Judger');
    require(judger == msg.sender);
    // require(judgmentStartTime == 0, 'F:makeJudgment');
    require(judgmentStartTime == 0);
    // require(feeRate >= 0, 'F:is0');
    require(feeRate > 0);
    judgeFeeRateZeroPending = true;
  }

  // follow some side by token, not just talk.
  // Talk is cheap, show me the token.
  // yes, you can send token by set another profiteer.
  // because Cobie hse two pair competitor.
  // if you want to set to black hole, use 0x0000...dead .
  function addPair(address _profiteTo, address _token, uint _amount, bool _IsLeftSide, string calldata memo, string calldata memoUri) external {
    // ensure not try to annonce.
    // dont let user make mistakes.
    // require(judgmentStartTime == 0, 'F:startd');
    require(judgmentStartTime == 0);

    // require(address(_token) == _token, 'F:token');
    // require(_profiteTo != address(0), 'F:profiteTo');
    // require(_amount > 0, 'F:Amount');
    require(_amount > 0);

    uint _balance = IERC20(_token).balanceOf(address(this));
    // require(_balance >= _amount.add(reserve[_token]), 'F:K');
    require(_balance >= _amount.add(reserve[_token]));

    // need to init length;
    status.push(statusDefault);

    if (_IsLeftSide) {
      leftSide.push(_profiteTo);
      rightSide.push(address(0));

      memoRightSide.push('');
      memoUriRightSide.push('');
      memoLeftSide.push(memo);
      memoUriLeftSide.push(memoUri);
    }
    else {
      leftSide.push(address(0));
      rightSide.push(_profiteTo);
      memoRightSide.push(memo);
      memoUriRightSide.push(memoUri);
      memoLeftSide.push('');
      memoUriLeftSide.push('');
    }

    amount.push(_amount);
    token.push(_token);

    reserve[_token] = _balance;
  }

  // join pairs.
  // same means of addPair but joinPair need some addPair before.
  function joinPair(uint _appendId, address _profiteTo, address _token, uint _amount, bool _IsLeftSide, string calldata memo, string calldata memoUri) external lockNotAnnounced {
    // ensure not try to annonce.
    // dont let user make mistakes.
    // if try to announce, please your abort.
    // require(judgmentStartTime == 0, 'F:startd');
    require(judgmentStartTime == 0);

    uint _balance = IERC20(_token).balanceOf(address(this));
    // require(_balance >= _amount.add(reserve[_token]), 'F:K');
    require(_balance >= _amount.add(reserve[_token]));

    // require(token[_appendId] == _token, 'F:token');
    require(token[_appendId] == _token);
    // require(_profiteTo != address(0), 'F:profiteTo');
    // require(amount[_appendId] == _amount, 'F:Amount');
    require(amount[_appendId] == _amount);

    if (_IsLeftSide) {
      // require(leftSide[_appendId] == address(0), 'F:leftSide1');
      require(leftSide[_appendId] == address(0));
      // require(rightSide[_appendId] != address(0), 'F:rightSide1');
      require(rightSide[_appendId] != address(0));
      leftSide[_appendId] = _profiteTo;

      memoLeftSide[_appendId] = memo;
      memoUriLeftSide[_appendId] = memoUri;
    }
    else {
      // require(leftSide[_appendId] != address(0), 'F:leftSide2');
      require(leftSide[_appendId] != address(0));
      // require(rightSide[_appendId] == address(0), 'F:rightSide2');
      require(rightSide[_appendId] == address(0));
      rightSide[_appendId] = _profiteTo;

      memoRightSide[_appendId] = memo;
      memoUriRightSide[_appendId] = memoUri;
    }

    reserve[_token] = _balance;
  }

  function abort(uint _appendId) external {
    // require(status[_appendId] == statusDefault, 'F:statusDefault');
    require(status[_appendId] == statusDefault);

    address _leftSide = leftSide[_appendId];
    address _rightSide = rightSide[_appendId];
    address abortAddress = _leftSide != address(0) ? _leftSide : _rightSide;

    // require(_leftSide == address(0) || _rightSide == address(0), 'F:In');
    require(_leftSide == address(0) || _rightSide == address(0));
    // require(abortAddress == msg.sender, 'F:Owned');
    require(abortAddress == msg.sender);

    uint _amount = amount[_appendId];

    address _token = token[_appendId];

    TransferHelper.safeTransfer(_token, abortAddress, _amount);

    status[_appendId] = statusAbort;

    // when Announced, not need to change reserve
    if (!isAnnounced) {
      uint _balance = IERC20(_token).balanceOf(address(this));
      reserve[_token] = _balance;
    }
  }

  // if token has transfer fee, don't let it join by youself.
  // or no one can take it back.
  // i don't want to add a back door to transfer any token illegal
  function transferToWiner(address _token, address _winner, uint _winAmount) private {
    uint _fee = _winAmount.mul(feeRate).div(10000);
    uint _amount;
    if (_fee > 0) {
      TransferHelper.safeTransfer(_token, factory, _fee);
      TransferHelper.safeTransfer(_token, judger, _fee);
      _amount = _winAmount.mul(2).sub(_fee).sub(_fee);
    }
    else {
      _amount = _winAmount.mul(2);
    }

    TransferHelper.safeTransfer(_token, _winner, _amount);
  }

  function makeJudgment(bool _isLeftSideWin) external lockNotAnnounced {
    // require(judgmentPending == false, 'F:judgmentPending');
    require(judgmentPending == false);
    // require(msg.sender == judger, 'F:Judger');
    require(msg.sender == judger);
    // require(lockTime <= block.timestamp, 'F:lockTime');
    require(lockTime <= block.timestamp);

    // judgment can set later 1 days.
    // require((judgmentStartTime + 1 days) <= block.timestamp, 'F:Lock');
    require((judgmentStartTime + 1 days) <= block.timestamp);
    // require((judgmentStartTime + 10 minutes) <= block.timestamp);
    // require((judgmentStartTime + 10 seconds) <= block.timestamp);

    isLeftSideWin = _isLeftSideWin;
    // lock 1 days to ensure.
    // if something happen and need to reject, pleact contect us to rejuct it.
    judgmentStartTime = block.timestamp;
    judgmentPending = true;
  }

  // factory controller can change feeRate to zero when judge suggest to set feeRate to zero.
  function ensureFeeRateZero() external {
    // require(msg.sender == factory, 'F:Factory');
    require(msg.sender == factory);
    // require(judgmentStartTime == 0, 'F:makeJudgment');
    require(judgmentStartTime == 0);
    // require(feeRate >= 0, 'F:is0');
    require(feeRate >= 0);
    // require(judgeFeeRateZeroPending == true, 'F:Pending');
    require(judgeFeeRateZeroPending == true);
    feeRate = 0;
    judgeFeeRateZeroPending = false;
  }

  // factory controller can revert this if it's evil,
  // but factory controller will not do this
  function rejectJudgerment() external {
    // require(msg.sender == factory, 'F:Factory');
    require(msg.sender == factory);
    // require(judgmentPending == true, 'F:judgmentPending');
    require(judgmentPending == true);
    judgmentPending = false;
  }

  // any one can call this after time lock end;
  // ensure after 1 day since judger is make judgment
  function ensureJudgment() external lockNotAnnounced {
    // require(judgmentPending == true, 'F:judgmentPending');
    require(judgmentPending == true);
    // require(block.timestamp >= (judgmentStartTime + 1 days), 'F:Pending');
    require(block.timestamp >= (judgmentStartTime + 1 days));
    // require(block.timestamp >= (judgmentStartTime + 5 minutes));
    // require(block.timestamp >= (judgmentStartTime + 5 seconds));


    judgmentPending = false;
    isAnnounced = true;
    announcedTime = block.timestamp;
  }

  // you can call withdraw direct.
  // when Announced, can withdraw, not need to change reserve
  function withdraw(uint _appendId) external {
    // require(isAnnounced == true, 'F:isAnnounced');
    require(isAnnounced == true);

    // require(status[_appendId] == statusDefault, 'F:status');
    require(status[_appendId] == statusDefault);

    address _leftSide = leftSide[_appendId];
    address _rightSide = rightSide[_appendId];
    // require(_leftSide != address(0) || _rightSide != address(0), 'F:In');
    require(_leftSide != address(0) || _rightSide != address(0));

    address _winner;
    if (isLeftSideWin) {
      _winner = _leftSide;
    }
    else {
      _winner = _rightSide;
    }

    // if some one want to send gas to do call withdraw to other, very greate.
    // require winner to withdraw, by tx.origin, prepare for mint method in router.
    // require(msg.sender == _winner || tx.origin == _winner, 'F:winner');
    require(tx.origin == _winner);
    transferToWiner(token[_appendId], _winner, amount[_appendId]);
    status[_appendId] = statusWithdrawed;
  }

  // when this project is 365 days (always 1 year) since isAnnounced,
  // every one can take the token if someone not withdraw
  // we dont want the proj to archived in one way.
  function withdrawToken(address _token) public {
    // require(isAnnounced, 'F:isAnnounced');
    require(isAnnounced);
    // require(announcedTime + 365 days < block.timestamp, 'F:365');
    require(announcedTime + 365 days < block.timestamp);
    // require(announcedTime + 10 minutes < block.timestamp);
    // require(announcedTime + 10 seconds < block.timestamp);

    TransferHelper.safeTransfer(_token, msg.sender, IERC20(_token).balanceOf(address(this)));
  }

  // save size....
  // use by web.
  function getAllAddressData(uint _name) external view returns (address[] memory _all) {
    if (_name == 0) {
      _all = rightSide;
    }
    else if (_name == 1) {
      _all = leftSide;
    }
    else if (_name == 2) {
      _all = token;
    }
  }
  function getAddressDataByIndex(uint _name, uint _index) external view returns (address _data) {
    if (_name == 0) {
      _data = rightSide[_index];
    }
    else if (_name == 1) {
      _data = leftSide[_index];
    }
    else if (_name == 2) {
      _data = token[_index];
    }
  }
  function getAllUintData(uint _name) external view returns (uint[] memory _all) {
    if (_name == 3) {
      _all = amount;
    }
    else if (_name == 4) {
      _all = status;
    }
  }
  function getUintDataByIndex(uint _name, uint _index) external view returns (uint _data) {
    if (_name == 3) {
      _data = amount[_index];
    }
    else if (_name == 4) {
      _data = status[_index];
    }
  }

  function getAllStringData(uint _name) external view returns (string[] memory _all) {
    if (_name == 5) {
      _all = memoLeftSide;
    }
    else if (_name == 6) {
      _all = memoUriLeftSide;
    }
    else if (_name == 7) {
      _all = memoRightSide;
    }
    else if (_name == 8) {
      _all = memoUriRightSide;
    }
  }
  function geStringDataByIndex(uint _name, uint _index) external view returns (string memory _data) {
    if (_name == 5) {
      _data = memoLeftSide[_index];
    }
    else if (_name == 6) {
      _data = memoUriLeftSide[_index];
    }
    else if (_name == 7) {
      _data = memoRightSide[_index];
    }
    else if (_name == 8) {
      _data = memoUriRightSide[_index];
    }
  }
  // save size end
}
