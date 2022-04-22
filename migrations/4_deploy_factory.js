const fs = require('fs');
const saveInfo = require('./utils/save_info');

const Migrations = artifacts.require("Migrations");
const FeatureFactory = artifacts.require("FeatureFactory");

module.exports = async function (deployer, network, accounts) {
  let info = {};
  try {
    info = require('../build/info');
  }
  catch (err) {
    info = {};
  }

  if (['development', 'rinkeby', 'ropsten', 'kovan'].includes(network) || network.endsWith('-fork')) {
    // if not add this , $FeatureFactory will be undefined.
    const $Migrations = await deployer.deploy(Migrations);
  }

  const $FeatureFactory = await deployer.deploy(FeatureFactory);

  info.FeatureFactory = {
    address: $FeatureFactory.contract._address,
    abi: $FeatureFactory.abi,
    transactionHash: $FeatureFactory.transactionHash,
  };

  saveInfo(info);

};
