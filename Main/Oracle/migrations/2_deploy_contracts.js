const fs = require("fs");
const ATT = artifacts.require("ATT");

module.exports = async function (deployer, _network, addresses) {
    const [admin, _] = addresses;
    await deployer.deploy(ATT);
    let att = await deployer.deploy(ATT);

    var deploymentDic = {
        deployer: admin,
        attToken: att.address,
    };

    var deploymentDicString = JSON.stringify(deploymentDic);
    fs.writeFile(
        "attTokenDeployment.json",
        deploymentDicString,
        function (err, result) {
            if (err) console.log("error", err);
        }
    );
};
