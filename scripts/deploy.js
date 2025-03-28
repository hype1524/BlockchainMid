const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();  // Lấy tài khoản deploy

  console.log("Deploying contract với tài khoản:", deployer.address);

  const initialSupply = hre.ethers.parseUnits("1000000", 18); // 1 triệu token
  const MyToken = await hre.ethers.getContractFactory("MyToken");
  const myToken = await MyToken.deploy(initialSupply);

  await myToken.waitForDeployment();  // Chờ deploy xong

  console.log("✅ Hợp đồng MyToken được deploy tại:", await myToken.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
