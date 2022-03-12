import { expect, use } from "chai";
import { ethers } from "hardhat";
import { deployContract, MockProvider, solidity } from "ethereum-waffle"
import { BigNumber, Contract } from "ethers";
import Prime from "../artifacts/contracts/Prime.sol/Prime.json"
import Vault from "../artifacts/contracts/VaultWithInterest.sol/VaultWithInterest.json"


use(solidity);

describe("Vault", function () {
    const [walletDeployPrime, walletDeployVault] = new MockProvider().getWallets();
    let primeToken: Contract;
    let vaultContract: Contract;

    it("Should deposit 50 tokens into vault", async function () {
        primeToken = await deployContract(walletDeployPrime, Prime);
        vaultContract = await deployContract(walletDeployVault, Vault);
        let signedVaultContract = await vaultContract.connect(walletDeployPrime);
        await primeToken.approve(vaultContract.address, 100, { from: walletDeployPrime.address });
        await signedVaultContract.deposit(50, primeToken.address, { from: walletDeployPrime.address });
        expect(await primeToken.balanceOf(vaultContract.address)).to.equal(50);
    });

    it("Should calculate the interest earned on a given principle after 1 year and give us the number scaled by 1e15", async function () {
        vaultContract = await deployContract(walletDeployVault, Vault);
        let numberOfSecondsInAYear = 31536000;
        let result = await vaultContract.calculateInterestEarned(1000, 0, numberOfSecondsInAYear);
        expect(result).to.equal(BigNumber.from("10000000005120000"));
    });
});