//SPDX-License-Identifier: GPL LICENSE
pragma solidity ^0.8.9;

contract SafePurchase{
	uint public value;
	address payable seller;
	address payable buyer;

	enum State { Created, Locked, Release, Inactive}
	State public state;

	constructor() payable{
		seller = payable(msg.sender);
		value = msg.value/2;
	}

	/// The function cannot be executed in the current state
	error InvalidState();

	/// Only the buyer can invoke this function 
	error OnlyBuyer();

	/// Only the seller can invoke this function 
	error OnlySeller();	

	modifier inState(State state_){
		if(state != state_){
			revert InvalidState();
		}
		_;
	}

	modifier onlyBuyer(){
		if(msg.sender != buyer){
			revert OnlyBuyer();
		}
		_;
	}

	modifier onlySeller(){
		if(msg.sender != seller){
			revert OnlySeller();
		}
		_;
	}	

	function confirmPurchase() external inState(State.Created) payable{
		require(msg.value == 2 * value, "You must send 2x the price of the purchase");
		buyer = payable(msg.sender);
		state = State.Locked;
	}	

	function confirmReceived() external onlyBuyer inState(State.Locked){
		state = State.Release;
		buyer.transfer(value);
	}

	function paySeller() external onlySeller inState(State.Release){
		state = State.Inactive;
		seller.transfer(3 * value);
	}

	//To back out of transaction make contract state inactive and transfer the balance of the contract back to the seller who initialized it
	function abort() external onlySeller inState(State.Created){
		state = State.Inactive;
		seller.transfer(address(this).balance);
	}

}