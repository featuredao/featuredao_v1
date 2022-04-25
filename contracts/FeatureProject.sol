// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./TransferHelper.sol";
import "./IFeatureProject.sol";

contract FeatureProject {
  using SafeMath for uint;

  uint public lastPairId;

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

  mapping(uint => address) public leftSide;
  mapping(uint => address) public rightSide;

  uint constant statusDefault = 0;
  uint constant statusAbort = 1;
  uint constant statusWithdrawed = 2;
  // status default is 0, 1 is abort, 2 is withdrawed.
  mapping(uint => uint) public status;

  mapping(uint => uint) public amount;
  mapping(uint => address) public token;
  mapping(uint => string) public memoRightSide;
  mapping(uint => string) public memoUriRightSide;
  mapping(uint => string) public memoLeftSide;
  mapping(uint => string) public memoUriLeftSide;

  modifier lockNotAnnounced() {
    require(isAnnounced == false, 'isAnnounced');
    _;
  }

  constructor() {
    factory = msg.sender;
  }

  // only can initialize one time
  // lock by factory, because it will call just after created.
  function initialize(uint _lockTime, uint _feeRate, address _judger) external {
    require(msg.sender == factory, 'F');

    // only can initialize one time check,
    // when judger is set, it means Initializeed.
    require(judger == address(0), 'init');

    // make sure args valid
    require(_lockTime == 0 || _lockTime > block.timestamp, 'lock');
    require(_feeRate >= 30 && _feeRate <= 2000, 'feeRate');
    // require(_judger != address(0), 'Judger');

    judger = _judger;
    feeRate = _feeRate;
    lockTime = _lockTime;
  }

  // judger can change feeRate to zero
  function unsetFeeRate() external {
    require(judger == msg.sender, 'J');
    require(judgmentStartTime == 0, 'start');
    require(feeRate > 0, 'gt0');
    judgeFeeRateZeroPending = true;
  }

  // follow some side by token, not just talk.
  // Talk is cheap, show me the token.
  // yes, you can send token by set another profiteer.
  // because Cobie hse two pair competitor.
  // if you want to set to black hole, use 0x0000...dead .
  function addPair(address _profiteTo, address _token, uint _amount, bool _IsLeftSide, string calldata memo, string calldata memoUri) external returns (uint _pairId){
    // ensure not try to annonce.
    // dont let user make mistakes.
    require(judgmentStartTime == 0, 'start');

    // require(_profiteTo != address(0), 'profiteTo');
    require(_amount > 0, 'amount');

    uint _balance = IERC20(_token).balanceOf(address(this));
    require(_balance >= _amount.add(reserve[_token]), 'K');

    // begin from 1
    _pairId = lastPairId.add(1);

    // need to init length;
    status[_pairId] = statusDefault;
    amount[_pairId] = _amount;
    token[_pairId] = _token;
    reserve[_token] = _balance;

    if (_IsLeftSide) {
      leftSide[_pairId] = _profiteTo;
      memoLeftSide[_pairId] = memo;
      memoUriLeftSide[_pairId] = memoUri;
    }
    else {
      rightSide[_pairId] = _profiteTo;
      memoRightSide[_pairId] = memo;
      memoUriRightSide[_pairId] = memoUri;
    }

    lastPairId = _pairId;
  }

  // join pairs.
  // same means of addPair but joinPair need some addPair before.
  function joinPair(uint _pairId, address _profiteTo, address _token, uint _amount, bool _IsLeftSide, string calldata memo, string calldata memoUri) external lockNotAnnounced {
    // ensure not try to annonce.
    // dont let user make mistakes.
    // if try to announce, please your abort.
    require(judgmentStartTime == 0, 'start');

    uint _balance = IERC20(_token).balanceOf(address(this));
    require(_balance >= _amount.add(reserve[_token]), 'K');

    require(token[_pairId] == _token, 'token');

    // require(_profiteTo != address(0), 'profiteTo');
    require(amount[_pairId] == _amount, 'amount');

    if (_IsLeftSide) {
      require(leftSide[_pairId] == address(0), 'l1');
      require(rightSide[_pairId] != address(0), 'r1');
      leftSide[_pairId] = _profiteTo;

      memoLeftSide[_pairId] = memo;
      memoUriLeftSide[_pairId] = memoUri;
    }
    else {
      require(leftSide[_pairId] != address(0), 'l2');
      require(rightSide[_pairId] == address(0), 'r2');
      rightSide[_pairId] = _profiteTo;

      memoRightSide[_pairId] = memo;
      memoUriRightSide[_pairId] = memoUri;
    }

    reserve[_token] = _balance;
  }

  function abort(uint _pairId) external {
    require(status[_pairId] == statusDefault, 'status');

    address _leftSide = leftSide[_pairId];
    address _rightSide = rightSide[_pairId];
    address abortAddress = _leftSide != address(0) ? _leftSide : _rightSide;

    require(_leftSide == address(0) || _rightSide == address(0), 'ined');
    require(abortAddress == msg.sender, 'Owned');

    uint _amount = amount[_pairId];

    address _token = token[_pairId];

    TransferHelper.safeTransfer(_token, abortAddress, _amount);

    status[_pairId] = statusAbort;

    // when Announced, not need to change reserve
    if (!isAnnounced) {
      uint _balance = IERC20(_token).balanceOf(address(this));
      reserve[_token] = _balance;
    }
  }

  function makeJudgment(bool _isLeftSideWin) external lockNotAnnounced {
    require(judgmentPending == false, 'pending');
    require(msg.sender == judger, 'J');
    require(lockTime <= block.timestamp, 'lock');

    // judgment can set later 1 days.
    require((judgmentStartTime + 1 days) <= block.timestamp, 'lock1day');
    // require((judgmentStartTime + 10 minutes) <= block.timestamp, 'lock10m');
    // require((judgmentStartTime + 10 seconds) <= block.timestamp, 'lock10s');

    isLeftSideWin = _isLeftSideWin;
    // lock 1 days to ensure.
    // if something happen and need to reject, pleact contect us to rejuct it.
    judgmentStartTime = block.timestamp;
    judgmentPending = true;
  }

  // factory controller can change feeRate to zero when judge suggest to set feeRate to zero.
  function ensureFeeRateZero() external {
    require(msg.sender == factory, 'F');
    require(judgmentStartTime == 0, 'start');
    require(feeRate > 0, 'gt0');
    require(judgeFeeRateZeroPending == true, 'pending');
    feeRate = 0;
    judgeFeeRateZeroPending = false;
  }

  // factory controller can revert this if it's evil,
  // but factory controller will not do this
  function rejectJudgerment() external {
    require(msg.sender == factory, 'F');
    require(judgmentPending == true, 'pending');
    judgmentPending = false;
  }

  // any one can call this after time lock end;
  // ensure after 1 day since judger is make judgment
  function ensureJudgment() external lockNotAnnounced {
    require(judgmentPending == true, 'pending');
    require(block.timestamp >= (judgmentStartTime + 1 days), 'lock1days');
    // require(block.timestamp >= (judgmentStartTime + 5 minutes), 'lock5m');
    // require(block.timestamp >= (judgmentStartTime + 5 seconds), 'lock5s');


    judgmentPending = false;
    isAnnounced = true;
    announcedTime = block.timestamp;
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

  // you can call withdraw direct.
  // when Announced, can withdraw, not need to change reserve
  function withdraw(uint _appendId) external {
    require(isAnnounced == true, 'isAnnounced');

    require(status[_appendId] == statusDefault, 'status');

    address _leftSide = leftSide[_appendId];
    address _rightSide = rightSide[_appendId];
    require(_leftSide != address(0) || _rightSide != address(0), 'ined');

    address _winner;
    if (isLeftSideWin) {
      _winner = _leftSide;
    }
    else {
      _winner = _rightSide;
    }

    // if some one want to send gas to do call withdraw to other, very greate.
    // require winner to withdraw, by tx.origin, prepare for mint method in router.
    require(msg.sender == _winner || tx.origin == _winner, 'winner');
    transferToWiner(token[_appendId], _winner, amount[_appendId]);
    status[_appendId] = statusWithdrawed;
  }
}
