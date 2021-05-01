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


## If in middle transfer privillede is to be given use <IN ATT.sol  => "enableTransfer()">

## AFTER SALE <IN ATT.sol  => "setInitialDistributionFinished()">

