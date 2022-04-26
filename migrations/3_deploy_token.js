const fs = require('fs');
const saveInfo = require('./utils/save_info');

const Migrations = artifacts.require("Migrations");
const FeatureToken = artifacts.require("FeatureToken");

module.exports = async function (deployer, network, accounts) {
  let info = {};
  try {
    info = require(`../build/info.${network}`);
  }
  catch (err) {
    info = {};
  }

  const $Migrations = await Migrations.at(info.Migrations.address);

  const $FeatureToken = await deployer.deploy(FeatureToken);

  info.FeatureToken = {
    address: $FeatureToken.contract._address,
    abi: $FeatureToken.abi,
    transactionHash: $FeatureToken.transactionHash,
  };

  saveInfo(info, network);

};
