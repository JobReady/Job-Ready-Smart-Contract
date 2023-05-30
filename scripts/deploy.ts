import { ethers } from "hardhat";

async function main() {
  //npx hardhat run scripts/deploy.js --network theta_privatenet
  const [deployer] = await ethers.getSigners();

  console.log(
    "Deploying the contracts with the account:",
    await deployer.getAddress()
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const JobReadyNFT = await ethers.getContractFactory("JobReadyNFT");
  const jobNFT = await JobReadyNFT.deploy();

  await jobNFT.deployed();

  console.log("JobReadyNFT address:", jobNFT.address);


  const JobReadyContract = await ethers.getContractFactory("Job");
  const jobReady = await JobReadyContract.deploy(jobNFT.address);

  await jobReady.deployed();

  console.log("JobReady Contract Address", jobReady.address);


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
