const fs = require('fs');
const saveInfo = require('./utils/save_info');

const Migrations = artifacts.require("Migrations");
const FeatureProject = artifacts.require("FeatureProject");

module.exports = async function (deployer, network, accounts) {
  let info = {};
  try {
    info = require('../build/info');
  }
  catch (err) {
    info = {};
  }

  if (['development', 'rinkeby', 'ropsten', 'kovan'].includes(network) || network.endsWith('-fork')) {
    // if not add this , $FeatureToken will be undefined.
    const $Migrations = await deployer.deploy(Migrations);
  }
  // if not add this , $FeatureToken will be undefined.
  const $Migrations = await deployer.deploy(Migrations);

  const $FeatureProject = await deployer.deploy(FeatureProject);

  info.FeatureProject = {
    address: undefined,
    abi: $FeatureProject.abi,
    transactionHash: $FeatureProject.transactionHash,
  };

  saveInfo(info);
};
