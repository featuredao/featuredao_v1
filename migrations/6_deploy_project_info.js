const fs = require('fs');
const saveInfo = require('./utils/save_info');

const Migrations = artifacts.require("Migrations");
const FeatureProjectInfo = artifacts.require("FeatureProjectInfo");

module.exports = async function (deployer, network, accounts) {
  let info = {};
  try {
    info = require('../build/info');
  }
  catch (err) {
    info = {};
  }

  if (['development', 'rinkeby', 'ropsten', 'kovan'].includes(network) || network.endsWith('-fork')) {
    // if not add this , $FeatureProjectInfo will be undefined.
    const $Migrations = await deployer.deploy(Migrations);
  }

  const $FeatureProjectInfo = await deployer.deploy(FeatureProjectInfo);

  info.FeatureProjectInfo = {
    address: $FeatureProjectInfo.contract._address,
    abi: $FeatureProjectInfo.abi,
    transactionHash: $FeatureProjectInfo.transactionHash,
  };

  saveInfo(info);

};
