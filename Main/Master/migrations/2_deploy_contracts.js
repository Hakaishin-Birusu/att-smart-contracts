const Att = artifacts.require("Att");
const MarketOracle = artifacts.require("MarketOracle");
const Master = artifacts.require("Master");

module.exports = function (deployer) {
    deployer.then(async () => {
        // Deploy ATT ERC20
        await deployer.deploy(Att);
        let attAddress = await deployer.deploy(Att);

        // Deploy MarketOracle
        await deployer.deploy(MarketOracle);
        let marketOracleAddress = await deployer.deploy
        (MarketOracle, "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56",
         "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56" ,
        "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56");

        // Deploy Master and pass ATT ERC20 address
        await deployer.deploy(Master, attAddress.address);
        masterInstance = await Master.deployed();
        await masterInstance.setMarketOracle(marketOracleAddress.address);

        // set master address on ATT ERC20 contract
        let masterAdress = await deployer.deploy(Master, attAddress.address);
        attInstace = await Att.deployed();
        await attInstace.setMaster(masterAdress.address);
    })
};
