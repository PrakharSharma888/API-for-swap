const hre = require("hardhat");

async function main() {

  const token = await hre.ethers.getContractFactory("MyToken")
  const _token = await token.deploy()
  await _token.deployed()

  console.log("Token contract address", _token.address)

  const swap = await hre.ethers.getContractFactory("Exchange");
  const _swap = await swap.deploy(_token.address);

  await _swap.deployed();

  console.log(
    `Swap contract address ${_swap.address}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
