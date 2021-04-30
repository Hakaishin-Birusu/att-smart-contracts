// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./interfaces/IZelda.sol";

contract WatchTower {

    uint256 private maxRetPerStance = 5;
    IZelda public zelda;

    struct winnerStruct {
        address winnerAddress;
        uint256 claimAmount;
        uint256 position;
        bool hasPendingClaim;
    }

    constructor(
        address _zelda
    ) public {
        zelda = IZelda(_zelda);
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
}
