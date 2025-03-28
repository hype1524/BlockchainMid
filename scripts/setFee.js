const hre = require("hardhat");

async function main() {
    const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
    const newFee = 100;

    // Lấy account đầu tiên từ mạng Hardhat
    const [owner] = await hre.ethers.getSigners();

    // Kết nối với hợp đồng đã triển khai
    const MyToken = await hre.ethers.getContractFactory("MyToken");
    const contract = MyToken.attach(contractAddress);

    console.log(`Gọi setFeePercent(${newFee}) từ tài khoản: ${owner.address}`);

    // Gửi giao dịch để cập nhật phí
    const tx = await contract.connect(owner).setFeePercent(newFee);
    await tx.wait();

    console.log(`✅ Cập nhật phí thành công!`);
}

main().catch((error) => {
    console.error("❌ Lỗi:", error);
    process.exitCode = 1;
});
