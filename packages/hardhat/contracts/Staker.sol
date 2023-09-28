// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
	ExampleExternalContract public exampleExternalContract;
	address public owner;
	uint256 public deadline;
	uint256 public totalDeposits;
	uint256 public threshold;

	mapping(address => uint256) public deposits;

	event Stake(address indexed user, uint256 amount);
	event Withdrawn(address indexed user, uint256 amount);

	modifier onlyOwner() {
		require(msg.sender == owner, "Only the owner can call this function");
		_;
	}

	modifier beforeDeadline() {
		require(
			block.timestamp < deadline,
			"This action is only allowed before the deadline"
		);
		_;
	}

	modifier afterDeadline() {
		require(
			block.timestamp >= deadline,
			"This action is only allowed after the deadline"
		);
		_;
	}

	constructor(address _externalStaking) {
		exampleExternalContract = ExampleExternalContract(
			address(_externalStaking)
		);
		owner = msg.sender;
		deadline = block.timestamp + 5 * 1 minutes;
	}

	// Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
	// (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
	function stake() external payable {
		require(msg.value > 0, "Cant Deposit 0 Eth");
		deposits[msg.sender] += msg.value;
		threshold += msg.value;
    totalDeposits++;
		emit Stake(msg.sender, msg.value);
	}

	// After some `deadline` allow anyone to call an `execute()` function
	// If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
	function execute() external afterDeadline {
		if (threshold > 2) {
			exampleExternalContract.complete{ value: address(this).balance }();
		}
	}

	// If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
	function withdraw() external afterDeadline {
		payable(msg.sender).transfer(deposits[msg.sender]);
		deposits[msg.sender] = 0;
		emit Withdrawn(msg.sender, deposits[msg.sender]);
	}

	// Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
	function timeLeft() public view returns (uint256) {
		return deadline - block.timestamp;
	}

	// Add the `receive()` special function that receives eth and calls stake()
	receive() external payable {
		require(msg.value > 0, "Cant Send 0");
		this.stake{ value: msg.value }();
	}

function balanceOf(address account) public view returns (uint256) {
  return deposits[account];
}
}
