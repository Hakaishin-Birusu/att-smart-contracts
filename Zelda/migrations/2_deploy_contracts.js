const fs = require("fs");
const Zelda = artifacts.require("Zelda");

module.exports = async function (deployer, _network, addresses) {
    const [admin, _] = addresses;
  
    const attToken = "0xE0fFf84542A673F1FA053327eDe7DD95faF6ADD3";
  

    await deployer.deploy(Zelda, attToken);
    const zelda = await Zelda.deployed();

    var deploymentDic = {
        deployer: admin,
        attToken: attToken,
        zelda: zelda.address,
    };

    var deploymentDicString = JSON.stringify(deploymentDic);
    fs.writeFile(
        "zeldaDeployment.json",
        deploymentDicString,
        function (err, result) {
            if (err) console.log("error", err);
        }
    );
};
