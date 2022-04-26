const fs = require('fs');
const saveInfo = require('./utils/save_info');

// const Migrations = artifacts.require("Migrations");
const FeatureFactory = artifacts.require("FeatureFactory");




module.exports = async function (deployer, network, accounts) {
  if (network === 'development') {
    let info = {};
    try {
      info = require('../build/info');
    }
    catch (err) {
      info = {};
    }

    const $FeatureFactory = await FeatureFactory.at(info.FeatureFactory.address);

    await $FeatureFactory.createProj('1678809600', '30', [
      "Luna price will lower then 88 in 2023-03-14",
      "https://bafybeiawlg2qahublgfbbp4owkxqfucxehfoaheiuwulb2f4jdunmqfbdq.ipfs.dweb.link/luna.jpeg",
      "I think the 24hr average of the 14th of march in 2023 is lower then 88 at 14th match 2023.\nIf if true, Leftside win. Else RightSide win.\nI will make a fair judgment at 2023-03-15.\nEnjoy it.\n[inspire by the bet between Sensei Algod, Do Kwon and GCR for LUNA's price on 14th of March in 2023] \nsee: https://etherscan.io/address/0x4Cbe68d825d21cB4978F56815613eeD06Cf30152",
      "https://twitter.com/cobie/status/1503271489726185472",
    ], [
      "FeatureDao",
      "We are the FeatureDao group. Let's enjoy it.",
      "featuredao",
    ]);
  }
};
