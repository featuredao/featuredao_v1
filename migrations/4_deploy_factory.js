const fs = require('fs');
const saveInfo = require('./utils/save_info');

const Migrations = artifacts.require("Migrations");
const FeatureFactory = artifacts.require("FeatureFactory");

module.exports = async function (deployer, network, accounts) {
  let info = {};
  try {
    info = require(`../build/info.${network}`);
  }
  catch (err) {
    info = {};
  }

  const $Migrations = await Migrations.at(info.Migrations.address);

  const $FeatureFactory = await deployer.deploy(FeatureFactory);

  info.FeatureFactory = {
    address: $FeatureFactory.contract._address,
    abi: $FeatureFactory.abi,
    transactionHash: $FeatureFactory.transactionHash,
  };

  saveInfo(info, network);

};
