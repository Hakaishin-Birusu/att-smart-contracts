// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "./interfaces/IZelda.sol";
import "./interfaces/IXsafe.sol";
import "./interfaces/ILiquidFarm.sol";
import "./interfaces/IPledgeFarm.sol";
import "./interfaces/IMaster.sol";
import "./interfaces/IOracle.sol";
import "./interfaces/IAtt.sol";

contract WatchTower {

    uint256 private maxRetPerStance = 5;

    IZelda public zelda;
    IXsafe public xsafe;
    ILiquidFarm public liquid;
    IPledgeFarm public pledge;
    IMaster public master;
    IOracle public oracle;
    IAtt public att;

    struct winnerStruct {
        address winnerAddress;
        uint256 claimAmount;
        uint256 position;
        bool hasPendingClaim;
    }

    constructor(
        address _zelda,
        address _xsafe,
        address _liquid,
        address _pledge,
        address _master,
        address _oracle,
        address _att
    ) public {
        zelda = IZelda(_zelda);
        xsafe = IXsafe(_xsafe);
        liquid = ILiquidFarm(_liquid);
        pledge = IPledgeFarm(_pledge);
        master = IMaster(_master);
        oracle = IOracle(_oracle);
        att = IAtt(_att);
    }

    // function getCurrentBlock() public view returns (uint256) {
    //     return block.number;
    // }

    // function getCurrentTimestamp() public view returns (uint256) {
    //     return block.timestamp;
    // }

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
       price = xsafe.toAtt(1000000000000000000);
       estimatedValue = xsafe.toAtt(xBal);
    }

    function userStake(address _user) public view returns (uint256 bal, uint256 price, uint256 estimatedValue){
       (, bal ) = xsafe.getUserStat(_user);
       price = xsafe.toXAtt(1000000000);
       estimatedValue = xsafe.toXAtt(bal);
    }

    function stakeStats() public view returns (uint256 supply, uint256 price, uint256 xSafeBalance, uint256 attLocked){
       supply = xsafe.xattSupply();
       price = xsafe.toAtt(1000000000000000000);
       xSafeBalance = xsafe.getXsafeBalance();
       attLocked = xsafe.getAttPoolBalance() + xSafeBalance;
    }

    function userUnstakeLiquid(uint256 _pid, address _user) public view returns(uint256 stake, uint256 estReturn){
        (stake, estReturn) = liquid.pendingAtt(_pid, _user);
    }

    function userStakeLiquid(uint256 _pid,address _user) public view returns(uint256 stake, uint256 balance){
        balance = liquid.userLpBalance(_pid, _user);
        (stake, ) = liquid.pendingAtt(_pid, _user);   
    }

    function statsLiquid(uint256 _pid) public view returns(uint256 totalStaked, uint256 totalRewardLeft, uint256 resetblock){
        totalStaked = liquid.userLpBalance(_pid, address(liquid));
        totalRewardLeft = liquid.balance();
        resetblock = liquid.endBlock();
    }

    function userUnstakePledge(uint256 _pid, address _user) public view returns(uint256 stake, uint256 estReturnAtt, uint256 estReturnBusd){
        (stake, estReturnAtt, estReturnBusd) = pledge.pendingRewards(_pid, _user);
    }

    function userStakePledge(uint256 _pid,address _user) public view returns(uint256 stake, uint256 balance){
        balance = pledge.userLpBalance(_pid, _user);
        (stake, ,) = pledge.pendingRewards(_pid, _user);   
    }

    function statsPledge(uint256 _pid) public view returns(uint256 totalStaked, uint256 totalRewardLeftAtt, uint256 totalRewardLeftBusd,uint256 endblock){
        totalStaked = pledge.userLpBalance(_pid, address(liquid));
        totalRewardLeftAtt = pledge.balance();
        totalRewardLeftBusd = pledge.balanceBusd();
        endblock = pledge.endBlock();
    }

    function statsDash() public view returns(uint256 lastRebase, uint256 nextRebase){
        lastRebase = master.lastRebaseTimestampSec();
        nextRebase = master.cooldownExpiryTimestamp();
    }

    function primaryStatsDash() public view returns(uint256 totalAttLocked, uint256 totalBusdLocked, uint256 totalBnbAttLpLocked , uint256 oracleRate,uint256 targetPrice, uint256 circulatingSupply){
        oracleRate= oracle.getData();
        targetPrice= master.currentTargetRate();
        circulatingSupply= att.totalSupply();
        totalAttLocked = pledge.balance() + liquid.balance() + zelda.balance() + xsafe.getXsafeBalance() + xsafe.getAttPoolBalance();
        totalBusdLocked = pledge.balanceBusd();
        totalBnbAttLpLocked = liquid.userLpBalance(0, address(liquid)) + pledge.userLpBalance(0, address(pledge));
    }


}
