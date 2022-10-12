// SPDX-License-Identifier: UNLICENSE

pragma solidity >=0.5.0 < 0.9.0;

contract Lottery {
    address public manager;
    address payable[] public participants;

    constructor(){
        manager=msg.sender;
    }

    receive() external payable {
        require(msg.value==1 ether); // require minimum 1 ether
        participants.push(payable(msg.sender));
    } 

    function getBalance() public view returns(uint){

        require(msg.sender==manager);
        return address(this).balance;
    }


    function random() private view returns(uint){
        // for small project, dont use such random method in a industrial project.
        return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp,participants.length)));
    }

    function selectWinner() public{
        require(msg.sender==manager);
        require(participants.length>=3);
        uint rand = random();
        address payable winner;
        uint index = rand % participants.length;
        winner = payable(participants[index]);
        winner.transfer(getBalance());
        participants=new address payable[](0);
    }
}
