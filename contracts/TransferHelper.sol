// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

library TransferHelper {
  function safeApprove(address token, address to, uint value) internal {
    // bytes4(keccak256(bytes('approve(address,uint256)')));
    (bool _success, bytes memory _data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
    require(_success && (_data.length == 0 || abi.decode(_data, (bool))), 'FT: A_F');
  }

  function safeTransfer(address token, address to, uint value) internal {
    // bytes4(keccak256(bytes('transfer(address,uint256)')));
    (bool _success, bytes memory _data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
    require(_success && (_data.length == 0 || abi.decode(_data, (bool))), 'FT: T_F');
  }

  function safeTransferFrom(address token, address from, address to, uint value) internal {
    // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
    (bool _success, bytes memory _data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
    require(_success && (_data.length == 0 || abi.decode(_data, (bool))), 'FT: T_F_F');
  }

  function safeTransferETH(address to, uint value) internal {
    (bool _success,) = to.call{value:value}(new bytes(0));
    require(_success, 'FT: E_T_F');
  }
}
