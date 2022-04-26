const fs = require('fs');
const saveInfo = require('./utils/save_info');

const Migrations = artifacts.require("Migrations");
const FeatureRouter = artifacts.require("FeatureRouter");

module.exports = async function (deployer, network, accounts) {
  let info = {};
  try {
    info = require(`../build/info.${network}`);
  }
  catch (err) {
    info = {};
  }

  const $Migrations = await Migrations.at(info.Migrations.address);

  const $FeatureRouter = await deployer.deploy(FeatureRouter);

  info.FeatureRouter = {
    address: $FeatureRouter.contract._address,
    abi: $FeatureRouter.abi,
    transactionHash: $FeatureRouter.transactionHash,
  };

  saveInfo(info, network);

};
