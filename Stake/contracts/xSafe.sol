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
    address public attPool;
    uint256 public kLast;
    uint256 public attPerBlock;

    event Release(address indexed pool, uint256 releasedAmount, uint256 blockNumber);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor(IERC20 _att, uint256 _attPerBlock) public {
        att = _att;
        attPerBlock = _attPerBlock;
    }

    function releaseRewards() external {
        if (kLast != 0 && kLast < block.number) {
            uint256 amount = block.number.sub(kLast).mul(attPerBlock);
            _safeRelease(amount);
            kLast = block.number;
        }
    }

    function _safeRelease(uint256 _amount) internal {
        uint256 attBal = getXsafeBalance();
        if (_amount > attBal) {
            att.safeTransfer(attPool, attBal);
        } else {
            att.safeTransfer(attPool, _amount);
        }
        emit Release(attPool, _amount, block.number);
    }

    // EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _amount) external onlyOwner {
        att.safeTransfer(address(msg.sender), _amount);
        emit EmergencyWithdraw(msg.sender, _amount);
    }

    function updateXAtt(IERC20 _xAtt) external onlyOwner {
        xAtt = _xAtt;
    }

    function updateAttPool(address _attPool) external onlyOwner{
        attPool = _attPool;
    }

    function updateAttPerBlock(uint256 _attPerBlock) external onlyOwner{
        attPerBlock = _attPerBlock;
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
    
    function getEstimatedExchangeRate() public view returns (uint256 estimatedSupply, uint256 totalShares) {
        totalShares = xattSupply();
        uint256 attBal = getXsafeBalance();
        uint256 distribution = (block.number.sub(kLast)).mul(attPerBlock);
        if (distribution > attBal) {
            distribution = attBal;
        }
        estimatedSupply = (getAttPoolBalance()).add(distribution);
    }

    function toAtt(uint256 xAttAmount) external view returns (uint256 attAmount) {
        (uint256 estimatedSupply,uint256 totalShares) = getEstimatedExchangeRate();
        attAmount = (xAttAmount.mul(estimatedSupply)).div(totalShares);
    }

    function toXAtt(uint256 attAmount) external view returns (uint256 xAttAmount) {
        (uint256 estimatedSupply,uint256 totalShares) = getEstimatedExchangeRate();
        xAttAmount = (attAmount.mul(totalShares)).div(estimatedSupply);
    }

    function getAttPoolBalance() public view returns(uint256){
        return att.balanceOf(attPool);
    }

    function getXsafeBalance() public view returns(uint256){
        return att.balanceOf(address(this));
    }

    function xattSupply() public view returns(uint256){
        return xAtt.totalSupply();
    }

}
