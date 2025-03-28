// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    uint256 public feePercent = 10; // 0.1% phí (10 / 10000)
    address public feeReceiver; // Người nhận phí
    address public owner; // Lưu người tạo hợp đồng
    uint256 public distributionInterval = 30; // Khoảng thời gian phân phối (30 giây)
    uint256 public distributionAmount = 1 * 10 ** decimals(); // Số token phân phối mỗi lần
    mapping(address => uint256) public lastClaim; // Thời gian yêu cầu cuối cùng cho mỗi người nắm giữ

    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply * 10 ** decimals());
        feeReceiver = msg.sender; // Người nhận phí mặc định là người tạo hợp đồng
        owner = msg.sender; // Lưu địa chỉ owner
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function setFeePercent(uint256 newFee) external onlyOwner {
        require(newFee <= 100, "Fee cannot exceed 1% (100 / 10000)");
        feePercent = newFee;
    }

    function setDistributionAmount(uint256 amount) external onlyOwner {
        distributionAmount = amount * 10 ** decimals(); // Cập nhật số token phân phối
    }

    function claimTokens() external {
        uint256 timeElapsed = block.timestamp - lastClaim[msg.sender]; // Thời gian đã trôi qua

        require(timeElapsed >= distributionInterval, "You must wait before claiming again");

        _mint(msg.sender, distributionAmount); // Mint token cho người yêu cầu
        lastClaim[msg.sender] = block.timestamp; // Cập nhật thời gian yêu cầu
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * feePercent) / 10000;
        uint256 amountAfterFee = amount - fee;

        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        _transfer(msg.sender, feeReceiver, fee);
        _transfer(msg.sender, recipient, amountAfterFee);

        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * feePercent) / 10000;
        uint256 amountAfterFee = amount - fee;

        require(balanceOf(sender) >= amount, "Insufficient balance");

        _transfer(sender, feeReceiver, fee);
        _transfer(sender, recipient, amountAfterFee);

        uint256 currentAllowance = allowance(sender, msg.sender);
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }
}