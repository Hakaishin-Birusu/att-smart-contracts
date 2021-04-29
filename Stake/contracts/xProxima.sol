// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

interface IxSafe {
    function releaseX(uint256 _amount) external;
}

// You come in with some Pxa, and leave with more! The longer you stay, the more Pxa you get.
contract xProxima is ERC20("xProxima", "xPXA") {
    using SafeMath for uint256;
    IERC20 public pxa;
    address public devAddr;
    address public xSafeAddress;
    uint256 public kLastBlock;
    uint256 public perBlockDistribution;

    // Define the Pxa token contract
    constructor(
        IERC20 _pxa,
        address _xSafeAddress,
        uint256 _perBlockDistribution
    ) public {
        pxa = _pxa;
        devAddr = msg.sender;
        xSafeAddress = _xSafeAddress;
        perBlockDistribution = _perBlockDistribution;
    }

    // Enter the bar. Pay some PXA. Earn some shares.
    // Locks Pxa and mints xPxa
    function enter(uint256 _amount) public {
        // stop deposit if rewardpool is zero
        require(pxa.balanceOf(xSafeAddress) != 0, "xProxima : No Reward Left");
        updateXReserve();
        // Gets the amount of Pxa locked in the contract
        uint256 totalPxa = pxa.balanceOf(address(this));
        // Gets the amount of xPxa in existence
        uint256 totalShares = totalSupply();
        // If no xPxa exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalPxa == 0) {
            _mint(msg.sender, _amount);
            kLastBlock = block.number;
        }
        // Calculate and mint the amount of xPxa the Pxa is worth. The ratio will change overtime, as xPxa is burned/minted and Pxa deposited + gained from fees / withdrawn.
        else {
            uint256 what = _amount.mul(totalShares).div(totalPxa);
            _mint(msg.sender, what);
        }
        // Lock the Pxa in the contract
        pxa.transferFrom(msg.sender, address(this), _amount);
    }

    // Leave the bar. Claim back your PXA.
    // Unlocks the staked + gained Pxa and burns xPxa
    function leave(uint256 _share) public {
        updateXReserve();
        // Gets the amount of xPxa in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of Pxa the xPxa is worth
        uint256 what =
            _share.mul(pxa.balanceOf(address(this))).div(totalShares);
        _burn(msg.sender, _share);
        pxa.transfer(msg.sender, what);
    }

    function updateXReserve() internal {
        if (kLastBlock != 0 && kLastBlock < block.number) {
            uint256 amount =
                block.number.sub(kLastBlock).mul(perBlockDistribution);
            IxSafe(xSafeAddress).releaseX(amount);
            kLastBlock = block.number;
        }
    }

    function updatePerBlockDistribution(uint256 _perBlockDistribution)
        external
    {
        require(devAddr == msg.sender, "xProxima : Auth Failed");
        perBlockDistribution = _perBlockDistribution;
    }

    function getUserDepositStatus(address who)
        external
        view
        returns (uint256, uint256)
    {
        uint256 totalShares = totalSupply();
        uint256 distribution =
            (block.number.sub(kLastBlock)).mul(perBlockDistribution);
        if (distribution > pxa.balanceOf(xSafeAddress)) {
            distribution = pxa.balanceOf(xSafeAddress);
        }
        uint256 estimatedSupply =
            pxa.balanceOf(address(this)).add(distribution);
        return (
            balanceOf(who),
            balanceOf(who).mul(estimatedSupply).div(totalShares)
        );
    }
}
