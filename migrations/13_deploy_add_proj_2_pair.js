const fs = require('fs');
const saveInfo = require('./utils/save_info');

// const Migrations = artifacts.require("Migrations");
const FeatureFactory = artifacts.require("FeatureFactory");
const FeatureRouter = artifacts.require("FeatureRouter");




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
    const $FeatureRouter = await FeatureRouter.at(info.FeatureRouter.address);
    const project = await $FeatureFactory.getProject(2);


    const result = await $FeatureRouter.addPair(
      project,
      accounts[0],
      info.FeatureToken.address,
      '1',
      true,
      'memo',
      'https://bafybeiawlg2qahublgfbbp4owkxqfucxehfoaheiuwulb2f4jdunmqfbdq.ipfs.dweb.link/luna.jpeg',
    );
  }
};
