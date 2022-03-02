const { expect } = require("chai");
const {deployments} = require('hardhat');


describe("MyToken", function () {
  it("Should return the right name and symbol", async function () {

    await deployments.fixture(['MyTokenV2'])
    const MyToken = await ethers.getContract('MyTokenV2');
    expect(await MyToken.name()).to.equal("MyTokenV2");
    expect(await MyToken.symbol()).to.equal("MTKN");
  });
});

describe("MyTokenV2", function () {
  it("Should return the right correct mintLimit", async function () {

    await deployments.fixture(['MyTokenV2'])
    const MyToken = await ethers.getContract('MyTokenV2');
    expect(await MyToken.mintLimit()).to.equal(256);
  });
});
