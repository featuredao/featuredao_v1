const fs = require('fs');
const saveInfo = require('./utils/save_info');

// const Migrations = artifacts.require("Migrations");
const FeatureFactory = artifacts.require("FeatureFactory");




module.exports = async function (deployer, network, accounts) {
  let info = {};
  try {
    info = require('../build/info');
  }
  catch (err) {
    info = {};
  }

  const $FeatureFactory = await FeatureFactory.at(info.FeatureFactory.address);

  await $FeatureFactory.initialize(info.FeatureProjectInfo.address);
};
