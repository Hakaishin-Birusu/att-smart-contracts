// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;

interface IPledgeFarm {
    function balance() external view returns (uint256);
    function balanceBusd() external view returns (uint256);
    function pendingRewards(uint256, address) external view returns (uint256,uint256, uint256);
    function userLpBalance(uint256, address) external view returns(uint256);
    function endBlock() external view returns (uint256);
}
