const Tether = artifacts.require('Tether');
const RWD = artifacts.require('RWD');
const DecentralBank = artifacts.require('DecentralBank');

require('chai')
  .use(require('chai-as-promised'))
  .should();

contract('DecentralBank', ([owner, customer]) => {
  //All code for testing here
  let tether, rwd, decentralBank;

  const tokens = (n) => {
    return web3.utils.toWei(n, 'ether');
  };

  before(async () => {
    //load contracts
    tether = await Tether.new();
    rwd = await RWD.new();
    decentralBank = await DecentralBank.new(rwd.address, tether.address);

    //Trandfer all tokens to DecentralBank
    await rwd.transfer(decentralBank.address, tokens('1000000'));

    //Transfer 100 Tether to customer
    await tether.transfer(customer, tokens('100'), { from: owner });
  });

  describe('Mock Tether Deployment', async () => {
    it('matches name successfully', async () => {
      const name = await tether.name();
      assert.equal(name, 'Mock Tether Token');
    });
  });
  describe('Reward Token Deployment', async () => {
    it('matches name successfully', async () => {
      const name = await rwd.name();
      assert.equal(name, 'Reward Token');
    });
  });
  describe('DecentralBank Deployment', async () => {
    it('matches name successfully', async () => {
      const name = await decentralBank.name();
      assert.equal(name, 'DecentralBank');
    });
    it('contract has tokens', async () => {
      const balance = await rwd.balanceOf(decentralBank.address);
      assert.equal(balance, tokens('1000000'));
    });
  });
  describe('Yield Farming', async () => {
    it('rewards tokens for staking', async () => {
      let result;

      //Check investor's balance
      result = await tether.balanceOf(customer);
      assert.equal(
        result.toString(),
        tokens('100'),
        'customer mock wallet balance before staking '
      );

      //Check Staking For Customer
      await tether.approve(decentralBank.address, tokens('100'), {
        from: customer,
      });
      await decentralBank.depositTokens(tokens('100'), { from: customer });

      //Check Updated Balance of customer
      result = await tether.balanceOf(customer);
      assert.equal(
        result.toString(),
        tokens('0'),
        'customer mock wallet balance after staking '
      );

      // Check updated balance of DecentralBank
      result = await tether.balanceOf(decentralBank.address);
      assert.equal(
        result,
        tokens('100'),
        'decentral bank mock wallet balance after staking from customer'
      );

      //Check isStaking
      result = await decentralBank.isStaking(customer);
      assert.equal(result, true);

      //Check hasStaked
      result = await decentralBank.hasStaked(customer);
      assert.equal(result, true);

      //Issue Token
      await decentralBank.issueTokens({ from: owner });

      //Ensure only owner can issue tokens
      await decentralBank.issueTokens({ from: customer }).should.be.rejected;

      //Unstaking tokens
      await decentralBank.unstakingTokens({ from: customer });

      //Check balance after unstakingTokens
      result = await tether.balanceOf(customer);
      assert.equal(
        result.toString(),
        tokens('100'),
        'customer mock wallet balance after unstaking '
      );
      
      //Check reward token after unstaking
      result = await rwd.balanceOf(customer);
      assert.equal(
        result.toString(),
        tokens('10'),
        'customer reward after unstaking '
      );

      //Check isStaking
      result = await decentralBank.isStaking(customer);
      assert.equal(result, false);
      
      // Check updated tether balance of DecentralBank
      result = await tether.balanceOf(decentralBank.address);
      assert.equal(
        result,
        tokens('0'),
        'decentral bank mock wallet balance for tether after unstaking from customer'
      );

      // Check updated rwd balance of DecentralBank
      result = await rwd.balanceOf(decentralBank.address);
      assert.equal(
        result,
        tokens('999990'),
        'decentral bank mock wallet balance for rwd after unstaking from customer'
      );
      
    });
  });
});
