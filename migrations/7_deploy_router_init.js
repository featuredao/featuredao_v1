const { profileEnd } = require('console');
const fs = require('fs');
const saveInfo = require('./utils/save_info');

const Migrations = artifacts.require("Migrations");
const FeatureRouter = artifacts.require("FeatureRouter");
const WETH9 = artifacts.require("WETH9");

module.exports = async function (deployer, network, accounts) {
  let info = {};
  try {
    info = require('../build/info');
  }
  catch (err) {
    info = {};
  }

  const $FeatureRouter = await FeatureRouter.at(info.FeatureRouter.address);

  let WETHAddress = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2';
  if (['development'].includes(network)) {
    // // if not add this , $FeatureRouter will be undefined.
    const $Migrations = await deployer.deploy(Migrations);
    const $WETH9 = await deployer.deploy(WETH9);
    WETHAddress = $WETH9.contract._address;

    info.WETH = {
      address: $WETH9.contract._address,
      abi: $WETH9.abi,
      transactionHash: $WETH9.transactionHash,
    };

    saveInfo(info);
  }
  else if (['kovan'].includes(network)) {
    WETHAddress = '0xa1c74a9a3e59ffe9bee7b85cd6e91c0751289ebd';
  }

  await $FeatureRouter.initialize(info.FeatureFactory.address, WETHAddress);
};
