const fs = require("fs");
const WatchTower = artifacts.require("WatchTower");

module.exports = async function (deployer, _network, addresses) {
    const [admin, _] = addresses;
  
    const attToken = "0xE0fFf84542A673F1FA053327eDe7DD95faF6ADD3";
    const oracle = "0xE0fFf84542A673F1FA053327eDe7DD95faF6ADD3";
    const master = "0xE0fFf84542A673F1FA053327eDe7DD95faF6ADD3";
    const pledge = "0xE0fFf84542A673F1FA053327eDe7DD95faF6ADD3";
    const liquid = "0xE0fFf84542A673F1FA053327eDe7DD95faF6ADD3";
    const xsafe = "0xE0fFf84542A673F1FA053327eDe7DD95faF6ADD3";
    const zelda = "0xE0fFf84542A673F1FA053327eDe7DD95faF6ADD3";


    await deployer.deploy(WatchTower, zelda,
        xsafe,
        liquid,
        pledge,
        master,
        oracle,
        att);
    const watchtower = await WatchTower.deployed();

    var deploymentDic = {
        deployer: admin,
        watchtower: watchtower.address,
    };

    var deploymentDicString = JSON.stringify(deploymentDic);
    fs.writeFile(
        "WatchTowerDeployment.json",
        deploymentDicString,
        function (err, result) {
            if (err) console.log("error", err);
        }
    );
    
};
