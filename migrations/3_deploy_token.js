const fs = require('fs');
const saveInfo = require('./utils/save_info');

const Migrations = artifacts.require("Migrations");
const FeatureToken = artifacts.require("FeatureToken");

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

  const $FeatureToken = await deployer.deploy(FeatureToken);

  info.FeatureToken = {
    address: $FeatureToken.contract._address,
    abi: $FeatureToken.abi,
    transactionHash: $FeatureToken.transactionHash,
  };

  saveInfo(info);

};
