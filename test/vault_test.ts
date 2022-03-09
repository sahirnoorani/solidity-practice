import { expect, use } from "chai";
import { ethers } from "hardhat";
import { deployContract, MockProvider, solidity } from "ethereum-waffle"
import { BigNumber, Contract } from "ethers";
import Prime from "../artifacts/contracts/Prime.sol/Prime.json"
import Vault from "../artifacts/contracts/Vault.sol/Vault.json"


use(solidity);

describe("Vault", function () {
    const [walletDeployPrime, walletDeployVault] = new MockProvider().getWallets();
    let primeToken: Contract;
    let vaultContract: Contract;

    it("Should deposit 50 tokens into vault", async function () {
        primeToken = await deployContract(walletDeployPrime, Prime);
        vaultContract = await deployContract(walletDeployVault, Vault, [primeToken.address]);
        let signedVaultContract = await vaultContract.connect(walletDeployPrime);
        await primeToken.approve(vaultContract.address, 100, { from: walletDeployPrime.address });
        await signedVaultContract.deposit(50, { from: walletDeployPrime.address })
        expect(await primeToken.balanceOf(vaultContract.address)).to.equal(50);
        expect(await signedVaultContract.getUserBalance({ from: walletDeployPrime.address })).to.equal(50);
    });
});