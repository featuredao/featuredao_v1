const { initC } = require('./base_func');

contract('FeatureFactory', async (accounts) => {
  it("owner should be " + accounts[0], async () => {
    const $initC = await initC(accounts);
    return $initC.$FeatureToken.totalSupply.call().then((res) => {
      console.log('res', res.toString());
      assert.equal('1000000000000000000000000000', res.toString(), 'totalSupply should mint');
    });
  });
});
