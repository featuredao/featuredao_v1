const fs = require('fs');
const saveInfo = require('./utils/save_info');

// const Migrations = artifacts.require("Migrations");
const FeatureReader = artifacts.require("FeatureReader");

module.exports = async function (deployer, network, accounts) {
  let info = {};
  try {
    info = require('../build/info');
  }
  catch (err) {
    info = {};
  }

  const $FeatureReader = await FeatureReader.at(info.FeatureReader.address);

  await $FeatureReader.initialize(info.FeatureFactory.address, info.FeatureProjectInfo.address);
};
