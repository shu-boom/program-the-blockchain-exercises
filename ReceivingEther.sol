// Writing a Contract That Handles Ether
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReceivingEther {
    function getBalance() public view returns(uint){
        return address(this).balance;
    } 
    /*
        Deposit function to accept transaction with good practice of taking the amount as a param and checking it against the value provided in the transaction 
    */
    function deposit(uint amount) public payable {
        require(msg.value == amount);
    }

    /*
        Withraw using transafer method.
        Transfer: The transaction fails if it encounters any exception
        Send: Send returns true or false if the transfer succeds or fails. Therefore, it may be unsafe!
    */
    function withdraw(uint amount) public {
        require(amount<address(this).balance);
        payable(msg.sender).transfer(amount);
    }

    /*
        This is a fallback function. Having this allows this contract to receive ether. This may be unnecessary if it is okay to direct users to call the deposit method
        If a contract need to do direct tranfers to user's EOA and contract. THEN FALLBACK IS NECESSARY

        Gets only enough gas to log an event
    */
    fallback() external payable {

    }
}
