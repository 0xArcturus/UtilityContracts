// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


contract Proxy {
    event Deploy(address);


    recieve() external payable{}


    function deploy(bytes memory contractBytecode) external payable returns (address contractAddress) {
        assembly {
            //create(v, p , n)
            //v = amount of ETH to send, in this case callvalue() is msg.value
            //p = pointer in memory to the beginning of code,we add 0x20 which equals in decimal to 32 bytes to give the correct start in memory
            //n = size of the code, in this case we load from memory the bytecode


            addr := create(callvalue(), add(contractBytecode, 0x20), mload(contractBytecode))
        }

        require(addr != address(0), "deploy failed");

        emit Deploy(addr);
    }

    //The proxy can also execute any function in any contract, if we give the address of the contract and the calldata as inputs.
    //The calldata is a abi.encodeWithSignature of the function selector and the input.
    //With the manual encoding of the function selector we cover the necesity of the target contract's ABI
    function execute(address _target, bytes memory _data) external payable {
        (bool success,) = _target.call{value: msg.value}(_data);
        require(success, "failed")
    }
}


contract TestContract1 {
    address public owner = msg.sender;

    function setOwner(address newOwner) public {
        require(msg.sender == newOwner, "not owner");

        owner = newOwner
    }
}

contract TestContract2 {
    address public owner = msg.sender;
    uint public value = msg.value;
    uint public firstInt;
    uint public secondInt;

    constructor(uint a, uint b) payable {
        firstInt = a;
        secondInt = b;

    }

}


contract Helper {
    //this function returns the bytecode from any contract that doesnt have any inputs in the constructor
    function getBytecodeFromContractWithoutConstructorInputs() external pure returns (bytes memory) {
        bytes memory bytecode = type(TestContract1).creationCode;
        return bytecode
    }
    //this function returns the bytecode from the TestContract2. which requires constructor inputs
    //to do so, we first ask for the bytecode of the contract without inputs
    //once we have the bytecode we encodePacked the succesion of the bytecode and the encoded inputs,
    //this will give us the full bytecode ready to be deployed
    function getBytecodeFromContractWithConstructorInputs(uint a, uint b) external pure returns (bytes memory) {
        bytes memory bytecode = type(TestContract2).creationCode;
        return abi.encodePacked(bytecode, abi.encode(a,b));
    }


    //With this function we can get the full Calldata to execute the function setOwner,
    //to do so we encodeWithSignature the function selector and the input we want to give the function
    //Once we have this information we can call the execute function in a proxy, to execute the function through the contract
    function getSetOwnerCallData(address newOwner) external pure returns (bytes memory) {
        return abi.encodeWithSignature("setOwner(address)", newOwner)
    }
}