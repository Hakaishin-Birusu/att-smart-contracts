// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0;

interface IMaster {
    function lastRebaseTimestampSec() external view returns (uint256);
    function cooldownExpiryTimestamp() external view returns (uint256);
    function currentTargetRate() external view returns (uint256);
}
