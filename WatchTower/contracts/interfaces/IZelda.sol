// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;

interface IZelda {
    function pendingReward(address) external view returns (uint256);
    function getWinners(uint256) external view returns (address[] memory);
    function getCurrentCounter() external view returns (uint256);
}
