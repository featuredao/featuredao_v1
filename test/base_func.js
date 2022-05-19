const FeatureFactory = artifacts.require("FeatureFactory");
const FeatureRouter = artifacts.require("FeatureRouter");
const FeatureToken = artifacts.require("FeatureToken");
const FeatureProject = artifacts.require("FeatureProject");

async function initC(accounts) {
  var $FeatureFactory = await FeatureFactory.deployed({ from: accounts[2], gas: 5000000, gasPrice: 60000000 });
  var $FeatureRouter = await FeatureRouter.deployed({ from: accounts[2], gas: 5000000, gasPrice: 60000000 });
  var $FeatureToken = await FeatureToken.deployed({ from: accounts[2], gas: 5000000, gasPrice: 60000000 });

  return {
    FeatureProject,
    FeatureFactory,
    FeatureRouter,
    FeatureToken,
    $FeatureFactory,
    $FeatureRouter,
    $FeatureToken,
  };
}

module.exports = {
  initC,
};
