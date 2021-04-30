// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;

interface IXsafe {
    function getUserStat(address) external view returns (uint256, uint256);
    function toAtt(uint256) external view returns (uint256 );
    function toXAtt(uint256) external view returns (uint256 );
    function getXsafeBalance() external view returns(uint256);
    function getAttPoolBalance() external view returns(uint256);
    function xattSupply() external view returns(uint256);
}
