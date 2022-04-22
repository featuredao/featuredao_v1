const fs = require('fs');
const saveInfo = require('./utils/save_info');

// const Migrations = artifacts.require("Migrations");
const FeatureRouter = artifacts.require("FeatureRouter");




module.exports = async function (deployer, network, accounts) {
  let info = {};
  try {
    info = require('../build/info');
  }
  catch (err) {
    info = {};
  }

  const $FeatureRouter = await FeatureRouter.at(info.FeatureRouter.address);

  const WETHAddress = info.FeatureFactory.address;
  await $FeatureRouter.initialize(info.FeatureFactory.address, WETHAddress);
};
