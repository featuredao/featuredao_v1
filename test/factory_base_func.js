const { initC } = require('./base_func');

contract('FeatureFactory', async (accounts) => {
  it("owner should be " + accounts[0], async () => {
    const $initC = await initC(accounts);
    return $initC.$FeatureFactory.owner.call().then((owner) => {
      assert.equal(accounts[0], owner, 'owner should init');
    });
  });

  it("initialize WETHAddress " + accounts[1], async () => {
    const $initC = await initC(accounts);
    return $initC.$FeatureFactory.initialize(accounts[1], { from: accounts[0] }).then(() => {
      return $initC.$FeatureFactory.WETHAddress.call().then((WETHAddress) => {
        assert.equal(accounts[1], WETHAddress, 'WETHAddress should init');
      });
    });
  });

  it("initialize WETHAddress false use " + accounts[1], async () => {
    const $initC = await initC(accounts);
    try {
      await $initC.$FeatureFactory.initialize(accounts[1], { from: accounts[1] })
      assert.fail('initialize should not call');
    }
    catch (error) {
      assert.ok('initialize should not call');
    }
  });

  it("changeOwner " + accounts[1], async () => {
    const $initC = await initC(accounts);
    return $initC.$FeatureFactory.changeOwner(accounts[1], { from: accounts[0] }).then(() => {
      return $initC.$FeatureFactory.owner.call().then((owner) => {
        assert.equal(accounts[1], owner, 'owner should change');
      });
    });
  });

  it("changeOwner " + accounts[1], async () => {
    const $initC = await initC(accounts);
    try {
      await $initC.$FeatureFactory.changeOwner(accounts[1], { from: accounts[0] });
      assert.fail('changeOwner should not call');
    }
    catch (error) {
      assert.ok('changeOwner should not call');
    }
  });

  it("changeFeeTo " + accounts[1], async () => {
    const $initC = await initC(accounts);
    return $initC.$FeatureFactory.changeFeeTo(accounts[1], { from: accounts[0] }).then(() => {
      return $initC.$FeatureFactory.feeTo.call().then((feeTo) => {
        assert.equal(accounts[1], feeTo, 'feeTo should change');
      });
    });
  });

  it("changeJudgeController " + accounts[1], async () => {
    const $initC = await initC(accounts);
    return $initC.$FeatureFactory.changeJudgeController(accounts[1], { from: accounts[0] }).then(() => {
      return $initC.$FeatureFactory.judgeController.call().then((judgeController) => {
        assert.equal(accounts[1], judgeController, 'judgeController should change');
      });
    });
  });

  it("changeFeeController " + accounts[1], async () => {
    const $initC = await initC(accounts);
    return $initC.$FeatureFactory.changeFeeController(accounts[1], { from: accounts[0] }).then(() => {
      return $initC.$FeatureFactory.feeController.call().then((feeController) => {
        assert.equal(accounts[1], feeController, 'feeController should change');
      });
    });
  });

  it("withdrawFee " + accounts[1], async () => {
    const $initC = await initC(accounts);
    return $initC.$FeatureToken.transfer($initC.$FeatureFactory.address, '1000', { from: accounts[0] }).then(() => {
      return $initC.$FeatureFactory.withdrawFee($initC.$FeatureToken.address, { from: accounts[3] }).then(() => {
        return $initC.$FeatureFactory.feeController.call().then(() => {
          assert.ok('withdrawFee ok');
        }).catch(() => {
          assert.fail('withdrawFee fail');
        })
      });
    });
  });
  it("withdrawEthFee " + accounts[1], async () => {
    const $initC = await initC(accounts);

    return web3.eth.sendTransaction({ from: accounts[1], to: $initC.$FeatureFactory.address, value: '10000000000' }).then(() => {
      return $initC.$FeatureFactory.withdrawEthFee({ from: accounts[3] }).then(() => {
        return $initC.$FeatureFactory.feeController.call().then(() => {
          assert.ok('withdrawEthFee ok');
        }).catch(() => {
          assert.fail('withdrawEthFee fail');
        })
      });
    }).catch((err) => {
      assert.fail('withdrawEthFee fail');
    })
  });
});
