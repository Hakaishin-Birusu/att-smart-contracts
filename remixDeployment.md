## Deployment Guide

## TESTNET token address  & assumptions-
```
1. wbnb - 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
2. busd - 0xE28655080c356B0DF912025879171a0dcCa4E2DD
3. deployer & controller- 0x53D0Df043AF8232Fdf38Fd245Dfa4e681FF4Db99

# using bscswap on testnet  for testing

1. att/wbnb - 0x84E74F827245EC1a417d8933368106cf3c8BCfB5
2. wbnb/busd - 0x7C3Bef3b187EA44569d48E575734A1E02e38C804 

# add transaction testnet info
1. destination - 0x84E74F827245EC1a417d8933368106cf3c8BCfB5
b. data - 0xfff6cae9


```

# ATT token complete 

```
1. Deploy ATT token contract 
    a. NO constructor parameter 
    b. testnet address :- 0x01D3156549912d435B0feA7B4C229a9E1cB1723E

---------------------------------------------------------------------
2. Deploy Master -
    a. in contructor - pass "at token address"
    b. testnet address - 0x2bA2FD141f2b9c517144031b00Cb64714406fcCc // 4 mins rebase time 

---------------------------------------------------------------------
3. CREATE PAIR OF ATT/BNB in pancake

---------------------------------------------------------------------

4. Deploy Oracle -
    a. update wbnb & busd address in contract code
    b. in constructor - pass "controller" ,  "bnb/busd" , "bnb/ATT" LP token address // where controller is "master.so address"
    c. testnet address :- 0x456179Cf28A17F8eDBA6215775e4647557527985

---------------------------------------------------------------------

5. IMPORTANT - AFTER DEPLOYMENT SET BELOW FUNCTIONS
    a. ATT.sol => "setMaster()"
    b. Master.sol => "setMarketOracle()"

    <NOTE -  add "sync() CALL FOR PANACKE LP VIA "addTransaction("LP contract address", "Sync() bytes signature hash)">

```


# ZELDA deployment
```
1. Deployment contract 
    a. constrctor - attToken address 
    b. testnet deployment - 0x201E4cCbd22Be5aD221B045F66192401CcB2F1e1

2. FILL some ATT for reward distribution

points - winners mapping can be private
```

# STAKE (XATT) deployment
```
1. deploy xsafe contract
    a. constructor - attTOken address & tokensPerBlock value
    b. testnet deployment - 0x1C3Fc638d64D7202cB003FFBf23fBC0addA0881a

2. deploy xatt contract
    a. constructor - attTOken address & xSafe Address
    b. testnet deployment - 0xCAf86b877127f5840284065DD114f101B7f92DE3
    c. spawned pool address - 0x191C2764E1F7E9C390116F3dd71dD36772d3f3Bb

3. UPDATE functions in xSafe
    a. setAttPool()
    b. setXAtt()

4. FILL some ATT for reward distribution in xSafe
```

# FARM DEPLOYMENT

# LIQUID FARM
```
1. deploy liquid farm contract 
    a. constructor - attToken address , att token per block, start block , end block 
    b. testnet deployment - 0xe7a2861EAF22F8f0E9161d73E581D923Ea159284

2. Add LP token pool via "add()"

3. FILL some ATT for reward distribution in LiquidFarm contract
```

# PLEDGE FARM 
```
1. deploy Pledge farm contract 
    a. constructor - attToken address, busdtoken address , att token per block, busd token per block, start block , end block 
    b. testnet deployment - 0x465c9C9790E609332A94a8A494034459cE81A21B

2. 2. Add LP token pool via "add()"

3. FILL some ATT  & BUSD for reward distribution in Pledge contract
```


# WATCHTOWNER Deployment
```
1. deploy WatchTower contract 
    a. constructor - added all the contracts  in the constractor call 
    b. testnet deployment - 0x31835c6dd2130626a1BF65B521E4172522aFF324

```



## If in middle transfer privillede is to be given use <IN ATT.sol  => "enableTransfer()">

## AFTER SALE <IN ATT.sol  => "setInitialDistributionFinished()">

