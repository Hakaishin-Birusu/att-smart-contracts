const fs = require("fs");
const xAtt = artifacts.require("xAtt");
const xSafe = artifacts.require("xSafe");

module.exports = async function (deployer, _network, addresses) {
    const [admin, _] = addresses;
  
    const attToken = "0xE0fFf84542A673F1FA053327eDe7DD95faF6ADD3";
    const attPerBlock = 100000000;

    await deployer.deploy(xSafe, attToken, attPerBlock);
    const xsafe = await xSafe.deployed();

    await deployer.deploy(xAtt, attToken, xsafe.address);
    const xatt = await xAtt.deployed();

    const xattInstance = await xAtt.at(xatt.address);
    const tokenpool = await xattInstance.attPool();
    console.log("tokenpool", tokenpool);

    const xsafeInstance = await xSafe.at(xsafe.address);
    await xsafeInstance.updateXAtt(xatt.address);
    await xsafeInstance.updateAttPool(tokenpool);

    var deploymentDic = {
        deployer: admin,
        attToken: attToken,
        xsafe: xsafe.address,
        xatt: xatt.address,
        tokenpool: tokenpool,
    };

    var deploymentDicString = JSON.stringify(deploymentDic);
    fs.writeFile(
        "xattDeployment.json",
        deploymentDicString,
        function (err, result) {
            if (err) console.log("error", err);
        }
    );
};
