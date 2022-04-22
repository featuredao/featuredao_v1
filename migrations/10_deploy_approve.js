const fs = require('fs');
const saveInfo = require('./utils/save_info');

// const Migrations = artifacts.require("Migrations");
const FeatureToken = artifacts.require("FeatureToken");




module.exports = async function (deployer, network, accounts) {
  // if (network === 'development') {
  //   let info = {};
  //   try {
  //     info = require('../build/info');
  //   }
  //   catch (err) {
  //     info = {};
  //   }

  //   const $FeatureToken = await FeatureToken.at(info.FeatureToken.address);

  //   await $FeatureToken.approve(info.FeatureRouter.address, '11111111111111111111111111111111111');
  // }
};
