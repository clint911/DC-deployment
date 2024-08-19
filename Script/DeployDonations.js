const { ethers } = require("hardhat")

async function main(){
//
  //Assign the first signer, which comes from the first privateKey from our configuration in hardhat.config.js, to a wallet variable
  let wallet = (await ethers.getSigners())[0];

/**Initializing Contact Factory Object, wallet/signer used for signing the contract calls/transactions with this contract **/
  console.log("wallet already set up", wallet);
  console.log("--------Getting contract factory object");
  const DonationsContract = await ethers.getContractFactory("Donations", wallet);
  /**Using already initialized contract factory object with our contract, we can invoke deploy function to deploy the contract **/
  console.log("Initializing Deployment........");
  const donationsContract = await DonationsContract.deploy(wallet);
  console.log("Deploying.....");
  await donationsContract.waitForDeployment();
  console.log("Deployment complete......Fetching Receipt.....");
  const donationsContractAddr = await donationsContract.deploymentTransaction.wait().contractAddress;
  console.log(`Contract deployed to: ${donationsContractAddr}`);
  const txReceipt = await donationsContract.deploymentTransaction();
  console.log(`Transaction Receipt ${txReceipt}`);
}
main()
