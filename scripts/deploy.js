const rando = (max) =>  {
  return Math.floor(Math.random() * max);
}

const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('Roshambo');
  const gameContract = await gameContractFactory.deploy(
    ["Texas Dolly", "The Brat", "Fivehead"],       // Names
    ["QmfWhDRVQnUeygHKz4tLWFSgNbGc8ZaPQJT7R74dt8GXjU", // Images
    "QmXuZ4yUjbQYYmQ9pm6KjYTt3d87yodhM6L4vqgVHT2EPc", 
    "QmNYv3qqUFf4erxQvwkCBhgNQ7LRb6imx2wpjf62veeueH"],
    [500, 200, 300],                    // Bankroll values
    "The Whale",
    "QmRez8UwDrooJd5JCfWun4YaNQLGvb5yrAzLs9W5f4ahwP",
    10000
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);
/*
  let txn;
  // We only have three characters.
  // an NFT w/ the character at index 2 of our array.
  txn = await gameContract.mintCharacterNFT(2);
  await txn.wait();

  txn = await gameContract.play(rando(3), 5);
  txn = await gameContract.play(rando(3), 5);
  txn = await gameContract.play(rando(3), 5);
  txn = await gameContract.play(rando(3), 5);
  txn = await gameContract.play(rando(3), 5);
  txn = await gameContract.play(rando(3), 5);
  txn = await gameContract.play(rando(3), 5);
  txn = await gameContract.play(rando(3), 5);
*/
  console.log("Done deploying and minting!");
  
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();