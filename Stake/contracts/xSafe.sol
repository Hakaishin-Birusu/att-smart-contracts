// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract xSafe is Ownable{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public att;
    IERC20 public xAtt;
    address public devAddr;
    address public attPool;
    uint256 public kLast;
    uint256 public attPerBlock;

    event Release(address indexed pool, uint256 releasedAmount, uint256 blockNumber);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor(IERC20 _att, IERC20 _xAtt, uint256 _attPerBlock, address _devAddr, address _attPool) public {
        att = _att;
        xAtt = _xAtt;
        devAddr = _devAddr;
        attPerBlock = _attPerBlock;
        attPool = _attPool;
    }

    function releaseRewards() external {
        if (kLast != 0 && kLast < block.number) {
            uint256 amount = block.number.sub(kLast).mul(attPerBlock);
            _safeRelease(amount);
            kLast = block.number;
        }
    }

    // EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _amount) external onlyOwner {
        att.safeTransfer(address(msg.sender), _amount);
        emit EmergencyWithdraw(msg.sender, _amount);
    }

    function updateDev(address _devaddr) external onlyOwner {
        devAddr = _devaddr;
    }

    function updateAttPool(address _attPool) external {
        require(devAddr == msg.sender, "XSAFE: AUTH_FAILED");
        attPool = _attPool;
    }

    function updateAttPerBlock(uint256 _attPerBlock) external {
        require(devAddr == msg.sender, "XSAFE: AUTH_FAILED");
        attPerBlock = _attPerBlock;
    }

    function _safeRelease(uint256 _amount) internal {
        uint256 attBal = getSafeBalance();
        if (_amount > attBal) {
            att.safeTransfer(attPool, attBal);
        } else {
            att.safeTransfer(attPool, _amount);
        }
        emit Release(attPool, _amount, block.number);
    }
    
    // View functions for frontend.
    function getUserStat(address who)
        external
        view
        returns (uint256 xBal, uint256 bal)
    {    
        xBal = xAtt.balanceOf(who);
        (uint256 estimatedSupply,uint256 totalShares) = getEstimatedExchangeRate();
        bal = xBal.mul(estimatedSupply).div(totalShares);
    }

    function getSafeBalance() public view returns(uint256){
        return att.balanceOf(address(this));
    }
    
    function getEstimatedExchangeRate() public view returns (uint256 estimatedSupply, uint256 totalShares) {
        totalShares = xAtt.totalSupply();
        uint256 attBal = getSafeBalance();
        uint256 distribution = (block.number.sub(kLast)).mul(attPerBlock);
        if (distribution > attBal) {
            distribution = attBal;
        }
        estimatedSupply = att.balanceOf(attPool).add(distribution);
    }

    function toAtt(uint256 xAttAmount) external view returns (uint256 attAmount) {
        (uint256 estimatedSupply,uint256 totalShares) = getEstimatedExchangeRate();
        attAmount = (xAttAmount.mul(estimatedSupply)).div(totalShares);
    }

    function toXAtt(uint256 attAmount) external view returns (uint256 xAttAmount) {
        (uint256 estimatedSupply,uint256 totalShares) = getEstimatedExchangeRate();
        xAttAmount = (attAmount.mul(totalShares)).div(estimatedSupply);
    }
}
