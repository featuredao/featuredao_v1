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

    await $FeatureFactory.createProj('1682179200', '30', [
      "Feature Dao Token Market Cap up to $10m",
      "https://bafybeievjcmbfe2bhmopp2iya4buqbvymwza2udntmuri257ysjofz2ryi.ipfs.dweb.link/moon.gif",
      "Will Feature Dao Token Market Cap up to $10million next year at 2023-04-22?\nLeftSide to be upper $10m;\nRightSide to be not.",
      "https://twitter.com/featuredao",
    ], [
      "FeatureDao",
      "We are Feature Dao Group.",
      "featuredao",
    ]);
  }
};
