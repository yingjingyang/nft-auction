const { ethers } = require("hardhat");
const { use, expect } = require("chai");
const { solidity } = require("ethereum-waffle");
const fs = require("fs");
const { utils } = require("ethers");

use(solidity);

describe("My Dapp", function () {
  let myContract;

  describe("YourContract", function () {
    it("Should deploy YourContract", async function () {
      const [owner,alice] = await ethers.getSigners();
      const YourCollectible = await ethers.getContractFactory("YourCollectible");

      let uploadedAssets = JSON.parse(fs.readFileSync("./uploaded.json"))
      let bytes32Array = []
      for (let a in uploadedAssets) {
        console.log(" 🏷 IPFS:", a)
        let bytes32 = utils.id(a)
        console.log(" #️⃣ hashed:", bytes32)
        bytes32Array.push(bytes32)
      }
      console.log(" \n")

      let yourCollectible = await YourCollectible.deploy(bytes32Array);
      yourCollectible = yourCollectible.connect(alice);
      await yourCollectible.mintItem("Qme9T6kxqGE13fFLMN7o1gPXnojgktmDPENDphkHf5gMsn");

    });

  });
});
