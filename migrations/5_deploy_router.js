const fs = require('fs');
const saveInfo = require('./utils/save_info');

const Migrations = artifacts.require("Migrations");
const FeatureRouter = artifacts.require("FeatureRouter");

module.exports = async function (deployer, network, accounts) {
  let info = {};
  try {
    info = require('../build/info');
  }
  catch (err) {
    info = {};
  }

  if (['development', 'rinkeby', 'ropsten', 'kovan'].includes(network) || network.endsWith('-fork')) {
    // if not add this , $FeatureRouter will be undefined.
    const $Migrations = await deployer.deploy(Migrations);
  }

  const $FeatureRouter = await deployer.deploy(FeatureRouter);

  info.FeatureRouter = {
    address: $FeatureRouter.contract._address,
    abi: $FeatureRouter.abi,
    transactionHash: $FeatureRouter.transactionHash,
  };

  saveInfo(info);

};
