const fs = require('fs');
const saveInfo = require('./utils/save_info');

const Migrations = artifacts.require("Migrations");

module.exports = async function (deployer, network, accounts) {

  let info = {};
  try {
    info = require(`../build/info.${network}`);
  }
  catch (err) {
    info = {};
  }


  await deployer.deploy(Migrations);
  const $Migrations = await deployer.deploy(Migrations);

  info.Migrations = {
    address: $Migrations.contract._address,
    abi: $Migrations.abi,
    transactionHash: $Migrations.transactionHash,
  };

  saveInfo(info, network);
};


