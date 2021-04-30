// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract PledgeFarm is Ownable {
    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct UserInfo 
    {
        uint256 amount;                 // How many LP tokens the user has provided.
        uint256 attRewardDebt;             // Reward debt.
        uint256 busdRewardDebt;
    }

    struct PoolInfo 
    {
        IERC20 lpToken;                 // Address of LP token contract.
        uint256 allocPoint;             // How many allocation points assigned to this pool.
        uint256 lastRewardBlock;        // Last block number that ATT distribution occured.
        uint256 accAttPerShare;        // Accumulated ATT per share, times 1e12.
        uint256 accBusdPerShare;
    }

    IERC20 public ATT;                 // ATT token
    IERC20 public BUSD;  
    PoolInfo[] public poolInfo;         // Info of each pool.
    uint256 public attPerBlock;        // ATT tokens created per block.
    uint256 public busdPerBlock; 
    uint256 public startBlock;          // The block number at which ATT distribution starts.
    uint256 public endBlock;            // The block number at which ATT distribution ends.
    uint256 public totalAllocPoint = 0; // Total allocation poitns. Must be the sum of all allocation points in all pools.

    mapping (uint256 => mapping (address => UserInfo)) public userInfo;     // Info of each user that stakes LP tokens.

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(IERC20 _ATT, IERC20 _BUSD, uint256 _attPerBlock, uint256 _busdPerBlock, uint256 _startBlock, uint256 _endBlock) public {
        ATT = _ATT;
        BUSD = _BUSD;
        attPerBlock = _attPerBlock;
        busdPerBlock = _busdPerBlock;
        startBlock = _startBlock;
        endBlock = _endBlock;
    }

    /**
     * @dev Adds a new lp to the pool. Can only be called by the owner. DO NOT add the same LP token more than once.
     * @param _allocPoint How many allocation points to assign to this pool.
     * @param _lpToken Address of LP token contract.
     * @param _withUpdate Whether to update all LP token contracts. Should be true if ATT distribution has already begun.
     */
    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accAttPerShare: 0,
            accBusdPerShare: 0
        }));
    }

    /**
     * @dev Update the given pool's ATT allocation point. Can only be called by the owner.
     * @param _pid ID of a specific LP token pool. See index of PoolInfo[].
     * @param _allocPoint How many allocation points to assign to this pool.
     * @param _withUpdate Whether to update all LP token contracts. Should be true if ATT distribution has already begun.
     */
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    /**
     * @dev Return reward multiplier over the given _from to _to blocks based on block count.
     * @param _from First block.
     * @param _to Last block.
     * @return Number of blocks.
     */
    function getMultiplier(uint256 _from, uint256 _to) internal view returns (uint256) {
        if (_to < endBlock) {
            return _to.sub(_from);
        } else if (_from >= endBlock) {
            return 0;
        } else {
            return endBlock.sub(_from);
        }     
    }

    /**
     * @dev View function to see pending ATT on frontend.
     * @param _pid ID of a specific LP token pool. See index of PoolInfo[].
     * @param _user Address of a specific user.
     * @return Pending ATT & BUSD.
     */
    function pendingRewards(uint256 _pid, address _user) external view returns (uint256, uint256, uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accAttPerShare = pool.accAttPerShare;
        uint256 accBusdPerShare = pool.accBusdPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 attReward = multiplier.mul(attPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accAttPerShare = accAttPerShare.add(attReward.mul(1e12).div(lpSupply));
            uint256 busdReward = multiplier.mul(busdPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accBusdPerShare = accBusdPerShare.add(busdReward.mul(1e12).div(lpSupply));
            
        }
        return (user.amount, user.amount.mul(accAttPerShare).div(1e12).sub(user.attRewardDebt),
        user.amount.mul(accBusdPerShare).div(1e12).sub(user.busdRewardDebt));
    }

    /**
     * @dev Update reward vairables for all pools. Be careful of gas spending!
     */
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    /**
     * @dev Update reward variables of the given pool to be up-to-date.
     * @param _pid ID of a specific LP token pool. See index of PoolInfo[].
     */
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 attReward = multiplier.mul(attPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accAttPerShare = pool.accAttPerShare.add(attReward.mul(1e12).div(lpSupply));
        uint256 busdReward = multiplier.mul(busdPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accBusdPerShare = pool.accBusdPerShare.add(busdReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    /**
     * @dev Deposit LP tokens to Faucet for ATT allocation.
     * @param _pid ID of a specific LP token pool. See index of PoolInfo[].
     * @param _amount Amount of LP tokens to deposit.
     */
    function deposit(uint256 _pid, uint256 _amount) public {
        require(_amount <= userLpBalance(_pid, msg.sender), "INSUFFICIENT_BALANCE");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accAttPerShare).div(1e12).sub(user.attRewardDebt);
            safeAttTransfer(msg.sender, pending);
            uint256 pendingBusd = user.amount.mul(pool.accBusdPerShare).div(1e12).sub(user.busdRewardDebt);
            safeBusdTransfer(msg.sender, pendingBusd);
        }
        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        user.amount = user.amount.add(_amount);
        user.attRewardDebt = user.amount.mul(pool.accAttPerShare).div(1e12);
        user.busdRewardDebt = user.amount.mul(pool.accBusdPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function userLpBalance(uint256 _pid, address _user ) public view returns(uint256){
        PoolInfo storage pool = poolInfo[_pid];
        return pool.lpToken.balanceOf(_user);
    }

    /**
     * @dev Withdraw LP tokens from MasterChef.
     * @param _pid ID of a specific LP token pool. See index of PoolInfo[].
     * @param _amount Amount of LP tokens to withdraw.
     */
    function withdraw(uint256 _pid, uint256 _amount) public {
        require(block.number > endBlock, "underbounds");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "Can't withdraw more token than previously deposited.");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accAttPerShare).div(1e12).sub(user.attRewardDebt);
        safeAttTransfer(msg.sender, pending);
        uint256 pendingBusd = user.amount.mul(pool.accBusdPerShare).div(1e12).sub(user.busdRewardDebt);
        safeBusdTransfer(msg.sender, pendingBusd);
        user.amount = user.amount.sub(_amount);
        user.attRewardDebt = user.amount.mul(pool.accAttPerShare).div(1e12);
        user.busdRewardDebt = user.amount.mul(pool.accBusdPerShare).div(1e12);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    /**
     * @dev Withdraw without caring about rewards. EMERGENCY ONLY.
     * @param _pid ID of a specific LP token pool. See index of PoolInfo[].
     */
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.attRewardDebt = 0;
        user.busdRewardDebt = 0;
    }

    /**
     * @dev Safe att transfer function, just in case if rounding error causes faucet to not have enough ATT.
     * @param _to Target address.
     * @param _amount Amount of ATT to transfer.
     */
    function safeAttTransfer(address _to, uint256 _amount) internal {
        uint256 attBalance = ATT.balanceOf(address(this));
        if (_amount > attBalance) {
            ATT.transfer(_to, attBalance);
        } else {
            ATT.transfer(_to, _amount);
        }
    }

    function safeBusdTransfer(address _to, uint256 _amount) internal {
        uint256 busdBalance = BUSD.balanceOf(address(this));
        if (_amount > busdBalance) {
            BUSD.transfer(_to, busdBalance);
        } else {
            BUSD.transfer(_to, _amount);
        }
    }

    /**
     * @dev Views total number of LP token pools.
     * @return Size of poolInfo array.
     */
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }
    
    /**
     * @dev Views total number of ATT tokens deposited for rewards.
     * @return ATT token balance of the faucet.
     */
    function balance() public view returns (uint256) {
        return ATT.balanceOf(address(this));
    }

    function balanceBusd() public view returns (uint256) {
        return BUSD.balanceOf(address(this));
    }

    /**
     * @dev Rescue reward tokens.
     */
    function rescueTokens(address to, uint256 value0, uint256 value1) external onlyOwner  {
        require(block.number > endBlock, "underbounds");
         ATT.transfer(to, value0);
         BUSD.transfer(to, value1);
    }

}