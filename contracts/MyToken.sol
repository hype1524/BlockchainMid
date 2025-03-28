// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    uint256 public feePercent = 10; // 0.1% phí (10 / 10000)
    address public feeReceiver; // Người nhận phí
    address public owner; // Lưu người tạo hợp đồng

    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply * 10 ** decimals());
        feeReceiver = msg.sender; // Người nhận phí mặc định là người tạo hợp đồng
        owner = msg.sender; // Lưu địa chỉ owner
    }

    // Modifier chỉ cho phép owner gọi hàm
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Cho phép owner thay đổi phí giao dịch (tối đa 1%)
    function setFeePercent(uint256 newFee) external onlyOwner {
        require(newFee <= 100, "Fee cannot exceed 1% (100 / 10000)");
        feePercent = newFee;
    }

    // Hàm chuyển tiền có tính phí
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * feePercent) / 10000; // Tính phí
        uint256 amountAfterFee = amount - fee;

        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        _transfer(msg.sender, feeReceiver, fee); // Gửi phí về người tạo
        _transfer(msg.sender, recipient, amountAfterFee); // Gửi phần còn lại

        return true;
    }

    // Hàm chuyển tiền thay mặt người khác (có tính phí)
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * feePercent) / 10000;
        uint256 amountAfterFee = amount - fee;

        require(balanceOf(sender) >= amount, "Insufficient balance");

        _transfer(sender, feeReceiver, fee); // Gửi phí về người tạo
        _transfer(sender, recipient, amountAfterFee); // Gửi phần còn lại

        uint256 currentAllowance = allowance(sender, msg.sender);
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }
}
