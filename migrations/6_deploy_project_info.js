const fs = require('fs');
const saveInfo = require('./utils/save_info');

const Migrations = artifacts.require("Migrations");
const FeatureProjectInfo = artifacts.require("FeatureProjectInfo");

module.exports = async function (deployer, network, accounts) {
  let info = {};
  try {
    info = require(`../build/info.${network}`);
  }
  catch (err) {
    info = {};
  }

  const $Migrations = await Migrations.at(info.Migrations.address);

  const $FeatureProjectInfo = await deployer.deploy(FeatureProjectInfo);

  info.FeatureProjectInfo = {
    address: $FeatureProjectInfo.contract._address,
    abi: $FeatureProjectInfo.abi,
    transactionHash: $FeatureProjectInfo.transactionHash,
  };

  saveInfo(info, network);

};
