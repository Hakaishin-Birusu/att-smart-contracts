// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./interfaces/IZelda.sol";
import "./interfaces/IXsafe.sol";

contract WatchTower {

    uint256 private maxRetPerStance = 5;
    IZelda public zelda;
    IXsafe public xsafe;

    struct winnerStruct {
        address winnerAddress;
        uint256 claimAmount;
        uint256 position;
        bool hasPendingClaim;
    }

    constructor(
        address _zelda,
        address _xsafe
    ) public {
        zelda = IZelda(_zelda);
        xsafe = IXsafe(_xsafe);
    }

    function getCurrentBlock() public view returns (uint256) {
        return block.number;
    }

    function getCurrentTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    function userClaim(address _user) public view returns(bool hasClaim, uint256 amount){
        amount = zelda.pendingReward(_user);
        if(amount > 0 ){
            hasClaim = true;
        }
    }

    function winHistory(uint256 _count) public view returns(winnerStruct[] memory winners){
        winners = new winnerStruct[](maxRetPerStance);
        address[] memory winArr = zelda.getWinners(_count);
        for (uint256 i = 0; i < maxRetPerStance; i++) {
            (bool hasClaim, uint256 amount) = userClaim(winArr[i]);
            winners[i].winnerAddress = winArr[i];
            winners[i].claimAmount = amount;
            winners[i].position = i+1;
            winners[i].hasPendingClaim = hasClaim;
    }
    }

    function currentZeldaCount() public view returns(uint256){
        return  zelda.getCurrentCounter();
    }

    function currentWin() public view returns (winnerStruct[] memory winners){
        uint256 currentCount = currentZeldaCount();
        winners = winHistory(currentCount);
    }

    function userUnStake(address _user) public view returns (uint256 xBal, uint256 price, uint256 estimatedValue){
       (xBal, ) = xsafe.getUserStat(_user);
       price = xsafe.toAtt(1);
       estimatedValue = xBal*price;
    }

    function userStake(address _user) public view returns (uint256 bal, uint256 price, uint256 estimatedValue){
       (, bal ) = xsafe.getUserStat(_user);
       price = xsafe.toXAtt(1);
       estimatedValue = bal*price;
    }

    function stakeStats() public view returns (uint256 supply, uint256 price, uint256 xSafeBalance, uint256 attLocked){
       supply = xsafe.xattSupply();
       price = xsafe.toAtt(1);
       xSafeBalance = xsafe.getXsafeBalance();
       attLocked = xsafe.getAttPoolBalance();
    }


}
