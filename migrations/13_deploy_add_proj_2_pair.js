const fs = require('fs');
const saveInfo = require('./utils/save_info');

// const Migrations = artifacts.require("Migrations");
const FeatureFactory = artifacts.require("FeatureFactory");
const FeatureRouter = artifacts.require("FeatureRouter");
const FeatureToken = artifacts.require("FeatureToken");

module.exports = async function (deployer, network, accounts) {
  if (network === 'development') {

    let info = {};
    try {
      info = require('../build/info');
    }
    catch (err) {
      info = {};
    }

    const $FeatureToken = await FeatureToken.at(info.FeatureToken.address);

    await $FeatureToken.approve(info.FeatureRouter.address, '11111111111111111111111111111111111');

    const $FeatureFactory = await FeatureFactory.at(info.FeatureFactory.address);
    const $FeatureRouter = await FeatureRouter.at(info.FeatureRouter.address);
    const project1 = await $FeatureFactory.getProject(1);

    await $FeatureRouter.addPair(
      project1,
      accounts[0],
      info.FeatureToken.address,
      '100000000000000000000',
      true,
      "I'm agree with Sensei Algod, I'm in.[I bet 100m usd]",
      "https://bafybeibqjuvw5ohueslffk7sebym7t43gxcaincmqkjszm3jo2j7yubxyi.ipfs.dweb.link/forg.gif",
    );

    await $FeatureRouter.joinPair(
      project1,
      accounts[0],
      1,
      info.FeatureToken.address,
      '100000000000000000000',
      false,
      "Ok,I'm in. (said by Do Kwon)",
      "https://bafybeieqelnrgopzkjbubiyodnkyg4zsxe4b4eozgfs7uirv4i5di4uoyy.ipfs.dweb.link/forg_up.jpeg",
    );

    const project2 = await $FeatureFactory.getProject(2);

    await $FeatureRouter.addPair(
      project2,
      accounts[0],
      info.FeatureToken.address,
      "100000000000000000000",
      true,
      "Of course.",
      "https://bafybeia4qgizhfu6iphax62cryyeputj5tarqsm6an7dtvrygmhq45axpa.ipfs.dweb.link/moon.gif",
    );

    await $FeatureRouter.addPair(
      project2,
      accounts[0],
      info.FeatureToken.address,
      "100000000000000000000",
      true,
      "Of course. Second pair",
      "https://bafybeia4qgizhfu6iphax62cryyeputj5tarqsm6an7dtvrygmhq45axpa.ipfs.dweb.link/moon.gif",
    );
  }
};
