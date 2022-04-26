const fs = require('fs');
const saveInfo = require('./utils/save_info');

// const Migrations = artifacts.require("Migrations");
const FeatureProjectInfo = artifacts.require("FeatureProjectInfo");

module.exports = async function (deployer, network, accounts) {
  let info = {};
  try {
    info = require(`../build/info.${network}`);
  }
  catch (err) {
    info = {};
  }

  const $FeatureProjectInfo = await FeatureProjectInfo.at(info.FeatureProjectInfo.address);

  await $FeatureProjectInfo.initialize(info.FeatureFactory.address);
};
