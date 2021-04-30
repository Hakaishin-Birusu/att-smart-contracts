const fs = require("fs");
const PledgeFarm = artifacts.require("PledgeFarm");

module.exports = async function (deployer, _network, addresses) {
    const [admin, _] = addresses;

    const attToken = "0xE0fFf84542A673F1FA053327eDe7DD95faF6ADD3";
    const busdToken = "0xE0fFf84542A673F1FA053327eDe7DD95faF6ADD3";
    const attPerBlock = 100000000;
    const busdPerBlock = 100000000;
    const startBlock = 100000000;
    const endBlock = 100000000;

    await deployer.deploy(PledgeFarm, attToken, busdToken, attPerBlock, busdPerBlock, startBlock, endBlock);
    const pledgefarm = await PledgeFarm.deployed();

    var deploymentDic = {
        deployer: admin,
        attToken: attToken,
        pledgefarm: pledgefarm.address,
    };

    var deploymentDicString = JSON.stringify(deploymentDic);
    fs.writeFile(
        "pledgeFarmDeployment.json",
        deploymentDicString,
        function (err, result) {
            if (err) console.log("error", err);
        }
    );
};