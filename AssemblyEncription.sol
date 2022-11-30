// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract AssemblyEncryption {
    function encrypt(
        string memory input,
        bool decrypt
    ) external pure returns (string memory) {
        bytes32 output;
        assembly {
            //this function converts a string into an array of bytes and saves it into b, which is the function output
            function stringToBytes(a) -> b {
                b := mload(add(a, 32))
            }
            //the next function will accept an input of 32 bytes and depending on the decrypt bool:
            //if true it will add 01 to each byte, therefore "encrypting" the string
            //if false it will subtract 01 to each byte therefore "decrypting" the string

            //it will store the result on slot 0x0 in memory, and once finished, load it on variable r
            function addToBytes(input, decrypt) -> r {
                if eq(decrypt, false) {
                    mstore(
                        0x0,
                        add(
                            input,
                            0x0101010101010101010101010101010101010101010101010101010101010101
                        )
                    )
                }
                if eq(decrypt, true) {
                    mstore(
                        0x0,
                        sub(
                            input,
                            0x0101010101010101010101010101010101010101010101010101010101010101
                        )
                    )
                }

                r := mload(0x0)
            }

            //we temporarily save the bytestring in a let, but the output variable is declared outside the assembly block
            let byteString := stringToBytes(input)
            output := addToBytes(byteString, decrypt)
        }

        //this last part is to convert the bytes32 output into a bytes(32) variable , and return it typecasting it as a string
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) bytesArray[i] = output[i];

        return string(bytesArray);
    }
}
