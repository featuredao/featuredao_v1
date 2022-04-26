const fs = require('fs');
const saveInfo = require('./utils/save_info');

const Migrations = artifacts.require("Migrations");
const FeatureReader = artifacts.require("FeatureReader");

module.exports = async function (deployer, network, accounts) {
  let info = {};
  try {
    info = require(`../build/info.${network}`);
  }
  catch (err) {
    info = {};
  }

  const $Migrations = await Migrations.at(info.Migrations.address);

  const $FeatureReader = await deployer.deploy(FeatureReader);

  info.FeatureReader = {
    address: $FeatureReader.contract._address,
    abi: $FeatureReader.abi,
    transactionHash: $FeatureReader.transactionHash,
  };

  saveInfo(info, network);
};
