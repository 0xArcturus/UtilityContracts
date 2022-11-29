// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MultiDelegateCall {
    error DelegateCallFailed();

    function MultiDelegateCall(bytes[] memory data)
        external
        payable
        returns (bytes[] memory results)
    {
        results = new bytes[](data.length); //initialize an array with size data.length   (the amount of function calls)

        for (uint i; i < data.length; i++) {
            (bool ok, bytes memory res) = address(this).delegatecall(data[i]);
            if (!ok) {
                revert DelegateCallFailed();
            }
            results[i] = res;
        }
    }
}

contract TestMultiDelegatecCall is MultiDelegateCall {
    event log(address caller, string func, uint i);

    function func1(uint x, uint y) external {
        emit log(msg.sender, "func1", x + y);
    }
    function func2() external returns(uint) {
        emit log(msg.sender, "func2", 2);
        return 1
    }
    ///BAD PRACTICE////////////////////////////////////////////////////////////
    //Its not safe to use multidelegateCall on contracts that use mint or any function that changes a state depending on msg.value

    //In this case, if the function mint() is called several times on a multicall, even though msg.value is 1 ETH, each time mint is called it will 
    //add that to the balance.
    mapping(address => uint) public balanceOf;
    function mint() external payable {
        balanceOf[msg.sender] += msg.value;
    }
}

contract Helper {
    function getFunc1Data(uint x, uint y) external pure returns(bytes memory ) {
        return abi.encodeWithSelector(TestMultiDelegatecCall.func1.selector, x, y);
    }

    function getFunc2Data() external pure returns (bytes memory) {
        return abi.encodeWithSelector(TestMultiDelegatecCall.func2.selector);
    }
    function getMintData() external pure returns(bytes memory){
        return abi.encodeWithSelector(TestMultiDelegatecCall.mint.selector);
    }
}