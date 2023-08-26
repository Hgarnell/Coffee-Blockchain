pragma solidity ^0.5.0;

contract Adoption {
    address[16] public adopters;

    function adopt(uint petId) public returns (uint) {
        require(petId >= 0 && petId <= 15); // petId must be between 0 and 15

        adopters[petId] = msg.sender; // msg.sender is the address of the person or smart contract who called this function

        return petId;
    }

    function getAdopters() public view returns (address[16] memory) {
        return adopters;
    }
}
