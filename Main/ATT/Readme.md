## PTBC

## IMPORTANT
1. Update addresses in smart contract to direct ATT
    a. MarketOracle - "_wbnb" & "_busd"

# Deployment 
1. Deploy Att.sol
2. Deploy Master.sol
update :
    a. Att=> set master  via "setMaster()"
    b. Master.sol => set market oracle via "setMarketOracle()"

# After Deployment
1. Add pool in pancake and "update" market oracle via update().


# Points to remember
1. initialDistributionLock => remove lock for token circulation
2. you can add exempted addree for transfer , etc before "initialDistributionLock" via "enableTransfer"

# ASK 
1. update "deviationThreshold" in master.sol , currently it uses 5% deviation