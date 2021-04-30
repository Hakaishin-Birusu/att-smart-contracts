const fs = require("fs");
const LiquidFarm = artifacts.require("LiquidFarm");

module.exports = async function (deployer, _network, addresses) {
    const [admin, _] = addresses;

    const attToken = "0xE0fFf84542A673F1FA053327eDe7DD95faF6ADD3";
    const attPerBlock = 100000000;
    const startBlock = 100000000;
    const endBlock = 100000000;

    await deployer.deploy(LiquidFarm, attToken, attPerBlock, startBlock, endBlock);
    const liquidfarm = await LiquidFarm.deployed();


    var deploymentDic = {
        deployer: admin,
        attToken: attToken,
        liquidfarm: liquidfarm.address,
    };

    var deploymentDicString = JSON.stringify(deploymentDic);
    fs.writeFile(
        "LiquidFarmDeployment.json",
        deploymentDicString,
        function (err, result) {
            if (err) console.log("error", err);
        }
    );
};
