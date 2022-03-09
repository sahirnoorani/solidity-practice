import { expect, use } from "chai";
import { ethers } from "hardhat";
import { deployContract, MockProvider, solidity } from "ethereum-waffle"
import { Contract } from "ethers";
import Prime from "../artifacts/contracts/Prime.sol/Prime.json"
import Treasury from "../artifacts/contracts/Treasury.sol/Treasury.json"
import { sign } from "crypto";


use(solidity);

describe("Treasury", function () {
    const [wallet] = new MockProvider().getWallets();
    let primeToken: Contract;
    let treasury: Contract;
    let signer: any;

    beforeEach(async () => {
        primeToken = await deployContract(wallet, Prime);
        treasury = await deployContract(wallet, Treasury);
        signer = { from: wallet.address };
    });

    it("Should deposit 1000 Prime tokens as collateral", async function () {
        await primeToken.approve(treasury.address, 1000, signer);
        await treasury.deposit(1000, primeToken.address, signer);
        expect(await treasury.getTokenCollateralBalance(primeToken.address, signer)).to.equal(1000);
    });

    it("Should mint 1000 PUSD tokens for the user and update loan balance", async function () {
        await primeToken.approve(treasury.address, 1000, signer);
        await treasury.deposit(1000, primeToken.address, signer);
        expect(await treasury.balanceOf(wallet.address)).to.equal(0);
        expect(await treasury.getOutstandingLoanAmount(signer)).to.equal(0);
        await treasury.takeLoan(1000, signer)
        expect(await treasury.balanceOf(wallet.address)).to.equal(1000);
        expect(await treasury.getOutstandingLoanAmount(signer)).to.equal(1000);
    });

    it("Should not allow wallet to take a loan", async function () {
        await expect(treasury.takeLoan(1000, signer)).to.be.revertedWith("Insufficient collateral")
    });
});