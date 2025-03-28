const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
const abi = [
    {
        "inputs": [{ "internalType": "uint256", "name": "newFee", "type": "uint256" }],
        "name": "setFeePercent",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [{ "internalType": "uint256", "name": "amount", "type": "uint256" }],
        "name": "setDistributionAmount",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "claimTokens",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
];

let web3;
let contract;
let userAccount;

async function connectWeb3() {
    if (window.ethereum) {
        web3 = new Web3(window.ethereum);
        await window.ethereum.request({ method: "eth_requestAccounts" });
        const accounts = await web3.eth.getAccounts();
        userAccount = accounts[0];
        contract = new web3.eth.Contract(abi, contractAddress);
        console.log("Đã kết nối MetaMask:", userAccount);
    } else {
        alert("Vui lòng cài đặt MetaMask!");
    }
}

async function updateFee() {
    const newFee = document.getElementById("feeInput").value;

    if (!userAccount) {
        alert("Vui lòng kết nối MetaMask trước!");
        return;
    }

    if (newFee < 0 || newFee > 100) {
        alert("Phí phải từ 0 đến 100 (tối đa 1%)!");
        return;
    }

    document.getElementById("status").innerText = "Đang cập nhật phí, vui lòng đợi...";

    try {
        await contract.methods.setFeePercent(newFee).send({ from: userAccount });
        document.getElementById("status").innerText = "✅ Cập nhật phí thành công!";
    } catch (error) {
        console.error("Lỗi khi gọi hợp đồng:", error);
        document.getElementById("status").innerText = "❌ Lỗi: " + error.message;
    }
}

async function updateDistributionAmount() {
    const newAmount = document.getElementById("distributionInput").value;

    if (!userAccount) {
        alert("Vui lòng kết nối MetaMask trước!");
        return;
    }

    document.getElementById("status").innerText = "Đang cập nhật số lượng phân phối, vui lòng đợi...";

    try {
        await contract.methods.setDistributionAmount(newAmount).send({ from: userAccount });
        document.getElementById("status").innerText = "✅ Cập nhật số lượng phân phối thành công!";
    } catch (error) {
        console.error("Lỗi khi gọi hợp đồng:", error);
        document.getElementById("status").innerText = "❌ Lỗi: " + error.message;
    }
}

async function claimTokens() {
    if (!userAccount) {
        alert("Vui lòng kết nối MetaMask trước!");
        return;
    }

    document.getElementById("status").innerText = "Đang yêu cầu token, vui lòng đợi...";

    try {
        await contract.methods.claimTokens().send({ from: userAccount });
        document.getElementById("status").innerText = "✅ Yêu cầu token thành công!";
    } catch (error) {
        console.error("Lỗi khi yêu cầu token:", error);
        document.getElementById("status").innerText = "❌ Lỗi: " + error.message;
    }
}

// Kết nối Web3 khi trang load
window.onload = connectWeb3;