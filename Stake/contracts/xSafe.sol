// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title : xSafe
 * @author : ProximusAlpha
 */

contract xSafe {
    /// @dev Proxima Token instance
    IERC20 public pxa;
    /// @dev xProxima address
    address public xProxima;
    /// @dev Proxima Dev address
    address public devAddr;

    /// @dev An event thats emitted when Pxa tokens are released.
    event XNotification(uint256 releasedAmount, uint256 blockNumber);

    /// @dev Initilizes PXA and dev
    constructor(IERC20 _pxa) public {
        pxa = _pxa;
        devAddr = msg.sender;
    }

    /**
     * @dev Releases Proxima token to xProxima.
     * @param _amount : Amount of Pxa released.
     */
    function releaseX(uint256 _amount) external {
        require(xProxima == msg.sender, "xSafe: Auth Failed");
        if (_amount > balanceX()) {
            _amount = balanceX();
        }
        pxa.transfer(xProxima, _amount);
        emit XNotification(_amount, block.number);
    }

    /**
     * @dev Sets xProxima.
     * @param _xProxima :  xProxima Address.
     */
    function updateX(address _xProxima) external {
        require(devAddr == msg.sender, "xSafe: Auth Failed");
        xProxima = _xProxima;
    }

    function balanceX() public view returns (uint256) {
        return pxa.balanceOf(address(this));
    }
}
