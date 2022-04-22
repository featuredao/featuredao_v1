const moment = require('moment');
const { initC } = require('./base_func');

contract('FeatureFactory and $initC.FeatureProject interact', async (accounts) => {
  it("create with lockTime ok", async () => {
    const $initC = await initC(accounts);
    return $initC.$FeatureFactory.createProj(
      moment().unix() + 10,
      '30',
      ['http://www.google.com', 'desc', 'http://example.com'],
      ['name', 'judgerdesc', 'twitter111'],
      { from: accounts[2], gas: 5000000, gasPrice: 500000000 }
    ).then((_project) => {
      // console.log('_project', _project);
      assert.ok('should create');
    }).catch((err) => {
      // console.log('err', err);
      assert.fail('should create');
    });
  });

  it("create with lockTime fail", async () => {
    const $initC = await initC(accounts);
    return $initC.$FeatureFactory.createProj(
      moment().unix(),
      '30',
      ['http://www.google.com', 'desc', 'http://example.com'],
      ['name', 'judgerdesc', 'twitter111'],
    ).then((_project) => {
      // console.log('_project', _project);
      // assert.equal(accounts[0], owner, 'owner should init');
      assert.fail('should not create');
    }).catch((err) => {
      // console.log('err', err);
      assert.ok('should not create');
    });
  });

  it("create with feeRate 2000 ok", async () => {
    const $initC = await initC(accounts);
    return $initC.$FeatureFactory.createProj(
      moment().unix() + 10,
      '2000',
      ['http://www.google.com', 'desc', 'http://example.com'],
      ['name', 'judgerdesc', 'twitter111'],
      { from: accounts[0], gas: 5000000, gasPrice: 500000000 }
    ).then((_project) => {
      // console.log('_project', _project.receipt.logs);
      assert.ok('should create');
    }).catch((err) => {
      // throw err;
      // // console.log('err', err);
      assert.fail('should create');
    });
  });

  it("create with feeRate 2001 fail", async () => {
    const $initC = await initC(accounts);
    return $initC.$FeatureFactory.createProj(
      moment().unix() + 10,
      '2001',
      ['http://www.google.com', 'desc', 'http://example.com'],
      ['name', 'judgerdesc', 'twitter111'],
      { from: accounts[0], gas: 5000000, gasPrice: 500000000 }
    ).then((_project) => {
      // console.log('_project', _project.receipt.logs);
      assert.fail('should create');
    }).catch((err) => {
      // throw err;
      // // console.log('err', err);
      assert.ok('should create');
    });
  });

  it("create with lockTime 0 should ok", async () => {
    const $initC = await initC(accounts);
    return $initC.$FeatureFactory.createProj(
      0,
      '30',
      ['http://www.google.com', 'desc', 'http://example.com'],
      ['name', 'judgerdesc', 'twitter111'],
      { from: accounts[2], gas: 5000000, gasPrice: 500000000 }
    ).then((_project) => {
      // console.log('_project', _project.receipt.logs);
      assert.ok('should create');
    }).catch((err) => {
      // throw err;
      // // console.log('err', err);
      assert.fail('should create');
    });
  });

  it("ensureFeeRateZero should fail", async () => {
    const $initC = await initC(accounts);
    return $initC.$FeatureFactory.createProj(
      0,
      '30',
      ['http://www.google.com', 'desc', 'http://example.com'],
      ['name', 'judgerdesc', 'twitter111'],
      { from: accounts[2], gas: 5000000, gasPrice: 500000000 }
    ).then((_project) => {
      // console.log('_project', _project.receipt.logs[0].args._projId);
      return $initC.$FeatureFactory.ensureFeeRateZero(_project.receipt.logs[0].args._projId).then((res) => {
        assert.fail('ensureFeeRateZero should fail');
      }).catch(() => {
        assert.ok('ensureFeeRateZero should fail');
      });
    }).catch((err) => {
      // throw err;
      // // console.log('err', err);
      assert.fail('should create');
    });
  });

  it("ensureFeeRateZero should ok", async () => {
    const $initC = await initC(accounts);
    return $initC.$FeatureFactory.createProj(
      0,
      '30',
      ['http://www.google.com', 'desc', 'http://example.com'],
      ['name', 'judgerdesc', 'twitter111'],
      { from: accounts[2], gas: 5000000, gasPrice: 500000000 }
    ).then((_project) => {
      const $project = new web3.eth.Contract($initC.FeatureProject._json.abi, _project.receipt.logs[0].args._project);
      const options = {
        from: accounts[2],
        to: $project._address,
        value: '0',
        data: $project.methods.unsetFeeRate().encodeABI(),
      };
      // console.log('options', options);
      return web3.eth.sendTransaction(options).then(() => {
        return $initC.$FeatureFactory.ensureFeeRateZero(_project.receipt.logs[0].args._projId).then((res) => {
          assert.ok('ensureFeeRateZero should ok');
        }).catch((err) => {
          console.log('err3', err);
          assert.fail('ensureFeeRateZero should ok');
        });
      }).catch((err) => {
        console.log('err2', err);
        assert.fail('unsetFeeRate should ok');
      })
    }).catch((err) => {
      // throw err;
      console.log('err1', err);
      assert.fail('should create');
    });
  });

  it("unsetFeeRate ok and ensureFeeRateZero fail", async () => {
    const $initC = await initC(accounts);
    return $initC.$FeatureFactory.createProj(
      0,
      '30',
      ['http://www.google.com', 'desc', 'http://example.com'],
      ['name', 'judgerdesc', 'twitter111'],
      { from: accounts[2], gas: 5000000, gasPrice: 500000000 }
    ).then((_project) => {
      const $project = new web3.eth.Contract($initC.FeatureProject._json.abi, _project.receipt.logs[0].args._project);
      const options = {
        from: accounts[2],
        to: $project._address,
        value: '0',
        data: $project.methods.unsetFeeRate().encodeABI(),
      };
      // console.log('options', options);
      return web3.eth.sendTransaction(options).then(() => {
        return $initC.$FeatureFactory.ensureFeeRateZero(_project.receipt.logs[0].args._projId, { from: accounts[1], gas: 5000000, gasPrice: 500000000 }).then((res) => {
          assert.fail('ensureFeeRateZero should fail');
        }).catch((err) => {
          // console.log('err3', err);
          assert.ok('ensureFeeRateZero should fail');
        });
      }).catch((err) => {
        console.log('err2', err);
        assert.fail('unsetFeeRate should ok');
      })
    }).catch((err) => {
      // throw err;
      console.log('err1', err);
      assert.fail('should create');
    });
  });

  it("unsetFeeRate should fail", async () => {
    const $initC = await initC(accounts);
    return $initC.$FeatureFactory.createProj(
      0,
      '30',
      ['http://www.google.com', 'desc', 'http://example.com'],
      ['name', 'judgerdesc', 'twitter111'],
      { from: accounts[2], gas: 5000000, gasPrice: 500000000 }
    ).then((_project) => {
      // console.log('_project', _project.receipt.logs[0]);
      const $project = new web3.eth.Contract($initC.FeatureProject._json.abi, _project.receipt.logs[0].args._project);
      const options = {
        from: accounts[1],
        to: $project._address,
        value: '0',
        data: $project.methods.unsetFeeRate().encodeABI(),
      };
      // console.log('options', options);
      return web3.eth.sendTransaction(options).then(() => {
        assert.fail('unsetFeeRate should fail');
      }).catch((err) => {
        // console.log('err2', err);
        assert.ok('unsetFeeRate should fail');
      })
    }).catch((err) => {
      // throw err;
      console.log('err1', err);
      assert.fail('should create');
    });
  });
});
