import { expect, use } from "chai";
import { ethers } from "hardhat";
import { deployContract, MockProvider, solidity } from "ethereum-waffle"
import { BigNumber, Contract } from "ethers";
import Prime from "../artifacts/contracts/Prime.sol/Prime.json"


use(solidity);

describe("Prime", function () {
    const [wallet] = new MockProvider().getWallets();
    let prime_token: Contract;

    it("Should mint the prime token and give the user who minted 100 prime tokens", async function () {
        prime_token = await deployContract(wallet, Prime);
        expect(await prime_token.balanceOf(wallet.address)).to.equal(100);
    });
});