// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;

interface IAtt {
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
}
