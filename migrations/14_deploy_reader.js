const fs = require('fs');
const saveInfo = require('./utils/save_info');

const Migrations = artifacts.require("Migrations");
const FeatureReader = artifacts.require("FeatureReader");

module.exports = async function (deployer, network, accounts) {
  let info = {};
  try {
    info = require('../build/info');
  }
  catch (err) {
    info = {};
  }

  if (['development', 'rinkeby', 'ropsten', 'kovan'].includes(network) || network.endsWith('-fork')) {
    // if not add this , $FeatureReader will be undefined.
    const $Migrations = await deployer.deploy(Migrations);
  }

  const $FeatureReader = await deployer.deploy(FeatureReader);

  info.FeatureReader = {
    address: $FeatureReader.contract._address,
    abi: $FeatureReader.abi,
    transactionHash: $FeatureReader.transactionHash,
  };

  saveInfo(info);
};
