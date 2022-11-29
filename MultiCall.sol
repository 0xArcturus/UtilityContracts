// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MultiCall {
    //A function where we give an array of contract addresses and an array of calldata to perform function calls

    //Multicall can execute function calls on different contracts, as long as we have the necessary calldata

    //To get whe calldata we need to abi.encodeWithSelector the function selector of the desired contract, followed by any inputs.abi

    //The function loops through the array and executes staticcalls with the data in the array.
    function multiCall(address[] calldata targets, bytes[] calldata data)
        external
        view
        returns (bytes[] memory)
    {
        require(
            targets.length == data.length,
            "number of targets and data isnt equal"
        );

        bytes[] memory results = new bytes[](data.length);

        for (uint i; i < targets.length; i++) {
            (bool success, bytes memory result) = targets[i].staticcall(
                data[i]
            );
            require(success, "call failed");
            results[i] = result;
        }

        return results;
    }
}

contract MultiCallTest {
    function test(uint input) external pure returns (uint) {
        return input;
    }

    function getCallData(uint input) external pure returns (bytes memory) {
        return abi.encodeWithSelector(this.test.selector, input);
    }
}
