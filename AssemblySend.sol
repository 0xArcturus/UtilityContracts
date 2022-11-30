// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract AssemblySend {
    address[2] owners = [
        0x684585A4E1F28D83F7404F0ec785758C100a3509,
        0x684585A4E1F28D83F7404F0ec785758C100a3509
    ];

    function withdrawEth(address to, uint256 amount) external payable {
        bool success;

        assembly {
            for {
                let i := 0
            } lt(i, 2) {
                i := add(i, 1)
            } {
                //we load storage array of owners individually into a memory variable
                let owner := sload(i)
                //we check with opcode eq if to is owner
                if eq(to, owner) {
                    //we send perform a call transaction and save the return bool onto success
                    success := call(gas(), to, amount, 0, 0, 0, 0)
                }
            }
        }
        require(success, "failed to send ETH")
    }
}
