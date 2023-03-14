const { expect } = require('chai');
const { ethers } = require('hardhat');
const { isCallTrace } = require('hardhat/internal/hardhat-network/stack-traces/message-trace');


describe("Demo", function() {
  let owner;
  let demo;

  beforeEach(async function() {
    [owner] = await ethers.getSigners();

    const Demo = await ethers.getContractFactory("libDemo", owner);
    demo = await Demo.deploy();
    await demo.deployed();
  });

  it("compare string", async function() {
    const result = await demo.runnerStr("cat", "cat");
    expect(result).to.eq(true);

    const result2 = await demo.runnerStr("cat", "dog");
    expect(result2).to.eq(false);
  })

  it("testing arrays", async function() {
    const result = await demo.runnerArr([1,2,3], 2);
    expect(result).to.eq(true);

    const result2 = await demo.runnerArr([1,2,3], 32);
    expect(result2).to.eq(false);
  })
  
})