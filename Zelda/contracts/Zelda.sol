// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract Zelda is Ownable, Pausable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public att;
    uint256 public totalAllocation;
    uint256 public counter;
    uint256 public MAX_POSITIONS;

    // dayCount / position / address
    mapping(uint256 => mapping(uint256 => address)) public winners;
    mapping(address => uint256) public userRewards;
    mapping(uint256 => uint256) public rewardScheme;
    mapping(address => bool) public nodes;

    constructor(IERC20 _att) public {
        att = _att;
        counter = 1;
        MAX_POSITIONS = 5;
    }

    event WinnerAnnouncement(address[] winners, uint256 indexed counter);
    event UserClaim(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);
    event RewardSchemeUpdate(uint256 indexed position, uint256 amount);

    modifier onlyNode() {
        require(nodes[msg.sender] == true, "ZELDA: AUTH_FAILED");
        _;
    }

    function announceWinner(address[] memory _wList)
        external
        onlyNode
        whenNotPaused
    {
        require(_wList.length == MAX_POSITIONS, "ZELDA: MAX_POSITIONS");
        for (uint256 i = 1; i <= MAX_POSITIONS; i++) {
            winners[counter][i] = _wList[i];
            userRewards[_wList[i]] = userRewards[_wList[i]].add(
                rewardScheme[i]
            );
            totalAllocation = totalAllocation.add((rewardScheme[i]));
        }
        counter++;
        emit WinnerAnnouncement(_wList, counter);
    }

    function claim() external whenNotPaused {
        uint256 claimAmount = userRewards[msg.sender];
        require(claimAmount > 0, "ZELDA : NO_CLAIM");
        userRewards[msg.sender] = 0;
        totalAllocation = totalAllocation.sub(claimAmount);
        att.safeTransfer(msg.sender, claimAmount);
        emit UserClaim(msg.sender, claimAmount);
    }

    function pendingReward(address _who) public view returns (uint256) {
        return userRewards[_who];
    }

    // EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _amount) external onlyOwner whenPaused {
        att.safeTransfer(address(msg.sender), _amount);
        emit EmergencyWithdraw(msg.sender, _amount);
    }

    function setNodeStatus(address _node, bool _status) external onlyOwner {
        nodes[_node] = _status;
    }

    function getCurrentCounter() external view returns (uint256) {
        return counter;
    }

    function getWinners(uint256 _count)
        external
        view
        returns (address[] memory res)
    {
        res = new address[](MAX_POSITIONS);
        for (uint256 i = 1; i <= MAX_POSITIONS; i++) {
            res[i] = winners[_count][i];
        }
    }

    function updateRewardScheme(uint256 _position, uint256 _amount)
        external
        onlyOwner
        whenPaused
    {
        rewardScheme[_position] = _amount;
        emit RewardSchemeUpdate(_position, _amount);
    }

    function getZeldaHolding() public view returns (uint256) {
        return att.balanceOf(address(this));
    }

    // pause & unpause

    function pause() external onlyOwner {
        _pause();
    }

    function unPause() external onlyOwner {
        _unpause();
    }
}
