const { profileEnd } = require('console');
const fs = require('fs');
const saveInfo = require('./utils/save_info');

const Migrations = artifacts.require("Migrations");
const FeatureRouter = artifacts.require("FeatureRouter");
const WETH9 = artifacts.require("WETH9");

module.exports = async function (deployer, network, accounts) {
  let info = {};
  try {
    info = require(`../build/info.${network}`);
  }
  catch (err) {
    info = {};
  }

  const $Migrations = await Migrations.at(info.Migrations.address);
  const $FeatureRouter = await FeatureRouter.at(info.FeatureRouter.address);

  // mainnet
  let WETHAddress = '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2';
  if (['development'].includes(network)) {
    const $WETH9 = await deployer.deploy(WETH9);
    WETHAddress = $WETH9.contract._address;

    info.WETH = {
      address: $WETH9.contract._address,
      abi: $WETH9.abi,
      transactionHash: $WETH9.transactionHash,
    };

    saveInfo(info, network);
  }
  else if (['rinkeby'].includes(network)) {
    // kovan
    WETHAddress = '0xdf032bc4b9dc2782bb09352007d4c57b75160b15';
  }
  else if (['kovan'].includes(network)) {
    // kovan
    WETHAddress = '0xa1c74a9a3e59ffe9bee7b85cd6e91c0751289ebd';
  }

  await $FeatureRouter.initialize(info.FeatureFactory.address, WETHAddress);
};
