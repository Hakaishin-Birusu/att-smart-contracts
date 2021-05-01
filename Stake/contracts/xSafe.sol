// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title xSafe contract
 */
contract xSafe is Ownable{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public att;
    IERC20 public xAtt;
    address public attPool;
    uint256 public kLast;
    uint256 public attPerBlock;

    event Release(address indexed pool, uint256 releasedAmount, uint256 blockNumber);

    constructor(IERC20 _att, uint256 _attPerBlock) public {
        att = _att;
        attPerBlock = _attPerBlock;
    }

    /**
     * @dev Release reward as per the blocks passed.
     */
    function releaseRewards() external {
        if (kLast != 0 && kLast < block.number) {
            uint256 amount = block.number.sub(kLast).mul(attPerBlock);
            kLast = block.number;
            safeTransfer(attPool, amount);
        }
    }

    /**
     * @dev Facilitates safe token transfer.
     */
    function safeTransfer(address _to, uint256 _amount) internal {
        uint256 Bal = getXsafeBalance();
        if (_amount > Bal) {
            _amount = Bal;
        }
        att.transfer(_to, _amount);
        emit Release(_to,_amount, block.number);
    }

    /**
     * @dev EMERGENCY ONLY. Withdraw ATT amount from zelda. 
     * @param _amount amount to be withdrawn.
     */
    function emergencyWithdraw(uint256 _amount) external onlyOwner {
        safeTransfer(address(msg.sender), _amount);
    }

    /**
     * @dev Sets xAtt token.
     * @param _xAtt xAtt token address.
     */
    function setXAtt(IERC20 _xAtt) external onlyOwner {
        xAtt = _xAtt;
    }

    /**
     * @dev Sets Token pool.
     * @param _attPool token pool address.
     */
    function setAttPool(address _attPool) external onlyOwner{
        attPool = _attPool;
    }

    /**
     * @dev Sets ATT distribution.
     * @param _attPerBlock amount of ATT distributed per block.
     */
    function setAttPerBlock(uint256 _attPerBlock) external onlyOwner{
        attPerBlock = _attPerBlock;
    }
    
    /**
     * @dev Returns user stats.
     * @param _who user's wallet address.
     */
    function getUserStat(address _who)
        external
        view
        returns (uint256 xBal, uint256 bal)
    {    
        xBal = xAtt.balanceOf(_who);
        (uint256 estimatedSupply,uint256 totalShares) = getEstimatedExchangeRate();
        bal = xBal.mul(estimatedSupply).div(totalShares);
    }
   
    /**
     * @dev Calculates & return estimated rates.
     */
    function getEstimatedExchangeRate() public view returns (uint256 estimatedSupply, uint256 totalShares) {
        totalShares = xattSupply();
        uint256 attBal = getXsafeBalance();
        uint256 distribution = (block.number.sub(kLast)).mul(attPerBlock);
        if (distribution > attBal) {
            distribution = attBal;
        }
        estimatedSupply = (getAttPoolBalance()).add(distribution);
    }

    /**
     * @dev Returns expected ATT for given XATT.
     * @param _xAttAmount amount.
     */
    function toAtt(uint256 _xAttAmount) external view returns (uint256 attAmount) {
        (uint256 estimatedSupply,uint256 totalShares) = getEstimatedExchangeRate();
        attAmount = (_xAttAmount.mul(estimatedSupply)).div(totalShares);
    }

    /**
     * @dev Returns expected XATT for given ATT.
     * @param _attAmount amount.
     */
    function toXAtt(uint256 _attAmount) external view returns (uint256 xAttAmount) {
        (uint256 estimatedSupply,uint256 totalShares) = getEstimatedExchangeRate();
        xAttAmount = (_attAmount.mul(totalShares)).div(estimatedSupply);
    }

    /**
     * @dev Returns Token pool balance.
     */
    function getAttPoolBalance() public view returns(uint256){
        return att.balanceOf(attPool);
    }

    /**
     * @dev Returns safe ATT balance.
     */
    function getXsafeBalance() public view returns(uint256){
        return att.balanceOf(address(this));
    }

    /**
     * @dev Returns xAtt supply.
     */
    function xattSupply() public view returns(uint256){
        return xAtt.totalSupply();
    }

}
