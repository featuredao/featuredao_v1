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

    await $FeatureFactory.createProj('0', '30', [
      "luna will go up[auto 2]",
      "https://bafybeiawlg2qahublgfbbp4owkxqfucxehfoaheiuwulb2f4jdunmqfbdq.ipfs.dweb.link/luna.jpeg",
      "Next year Luna's price will higer at this time",
      "https://twitter.com/cobie/status/1503271489726185472",
    ], [
      "Cobie[Auto 2]",
      "I get drunk every week on @uponlytv with a random dude from Alabama that I’ve never met.",
      "cobie",
    ]);
  }
};
