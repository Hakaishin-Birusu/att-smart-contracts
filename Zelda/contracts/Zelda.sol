// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title Zelda lottery contract
 */
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
        rewardScheme[1] = 500000000000; //$500
        rewardScheme[2] = 200000000000; //$200
        rewardScheme[3] = 100000000000; //$100
        rewardScheme[4] = 100000000000; //$100
        rewardScheme[5] = 100000000000; //$100
    }

    event WinnerAnnouncement(address[] winners, uint256 indexed counter);
    event Claim(address indexed user, uint256 amount);
    event RewardSchemeUpdate(uint256 indexed position, uint256 amount);

    modifier onlyNode() {
        require(nodes[msg.sender] == true, "ZELDA: AUTH_FAILED");
        _;
    }

  /**
     * @dev Notifies Zelda daily lottery winners.
     * Can only be called by trusted nodes.
     * @param _wList List of winners.
     */
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

  /**
     * @dev Transfers user win amount.
     */
    function claim() external whenNotPaused {
        uint256 claimAmount = userRewards[msg.sender]; // gas optimization
        require(claimAmount > 0, "ZELDA : NO_CLAIM");
        userRewards[msg.sender] = 0;
        totalAllocation = totalAllocation.sub(claimAmount);
        safeAttTransfer(msg.sender, claimAmount);
    }

     function safeAttTransfer(address _to, uint256 _amount) internal {
        uint256 Bal = balance();
        if (_amount > Bal) {
            _amount = Bal;
        }
        att.transfer(_to, _amount);
        emit Claim(_to,_amount);
    }

    /**
     * @dev Sets nodes status.
     * @param _node node address.
     * @param _status node status.
     */
    function setNode(address _node, bool _status) external onlyOwner {
        nodes[_node] = _status;
    }

    /**
     * @dev Updates reward allocation on specific position.
     * @param _position position on which reward is updated.
     * @param _amount new amount.
     */
    function updateRewardScheme(uint256 _position, uint256 _amount)
        external
        onlyOwner
        whenPaused
    {
        rewardScheme[_position] = _amount;
        emit RewardSchemeUpdate(_position, _amount);
    }


  /**
     * @dev Returns ATT balance of zelda.
     */
    function balance() public view returns (uint256) {
        return att.balanceOf(address(this));
    }

  /**
     * @dev Returns user's claimable ATT balance.
     * @param _who user's wallet address.
     */
    function pendingReward(address _who) public view returns (uint256) {
        return userRewards[_who];
    }

  /**
     * @dev Returns last zelda announcement count.
     */
    function getCurrentCounter() external view returns (uint256) {
        return counter;
    }

  /**
     * @dev Returns zelda winners.
     * @param _count zelda announcement count.
     */
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

    /**
     * @dev EMERGENCY ONLY. Withdraw ATT amount from zelda. 
     * @param _amount amount to be withdrawn.
     */
    function emergencyWithdraw(uint256 _amount) external onlyOwner whenPaused {
        safeAttTransfer(address(msg.sender), _amount);
    }

  /**
     * @dev Pause zelda state
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpause zelda state
     */
    function unPause() external onlyOwner {
        _unpause();
    }
}
