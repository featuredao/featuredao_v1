const fs = require('fs');
const saveInfo = require('./utils/save_info');

const Migrations = artifacts.require("Migrations");
const FeatureProject = artifacts.require("FeatureProject");

module.exports = async function (deployer, network, accounts) {
  let info = {};
  try {
    info = require(`../build/info.${network}`);
  }
  catch (err) {
    info = {};
  }

  const $Migrations = await Migrations.at(info.Migrations.address);

  const $FeatureProject = await deployer.deploy(FeatureProject);

  info.FeatureProject = {
    address: $FeatureProject.contract._address,
    abi: $FeatureProject.abi,
    transactionHash: $FeatureProject.transactionHash,
  };

  saveInfo(info, network);
};
