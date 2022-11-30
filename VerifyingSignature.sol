// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract VerifySignature {
    //how to sign message:
    //1. once you have the message, hash it
    //2. sign the hash offchain
    // 2.1 unlock metamask acc:   ethereum.enable()
    // 2.2 get message hash with our function and store it as variable on browser console:   hash = "0xhashresult"
    // 2.3 Sign message:                                                                     account = "our account address to sign"
    //                                                                                       ethereum.request({method: "personal_sign", params: [account, hash]}).then(console.log)

    //how to verify:
    //1. recreate hash from original message
    //2. recover signer from signature and hash
    //3. compare recovered signer to claimed signer

    function getMessageHash(
        address to,
        uint amount,
        string memory message,
        uint nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(to, amount, message, nonce));
    }

    function getEthSignedMessageHash(
        bytes32 messageHash
    ) public pure returns (bytes32) {
        //once we have the message hash, we can produce a signature with the format:  "\x19Ethereum Signed Message\n" + len(msg) + msg
        //in this case our messsage is 32 bytes
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    messageHash
                )
            );
    }

    // The function verify is the main function of this contract
    //The parameters to, amount, message and nonce are used to create the signedMessageHash
    //Whereas the parameters signer and signature are used to verify if the message is valid

    //The function creates a EthSignedMessage with the values and attempts to recover the signer with the signature we introduced
    //if any of the inputs is incorrect, the hashes wont match the signature,
    //and if the signer we inputed is incorrect, it wont be equal to the recovered signer
    function verify(
        address signer,
        address to,
        uint amount,
        string memory message,
        uint nonce,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(to, amount, message, nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == signer;
    }

    //THe function recoverSigner executes the solidity function ecrecover, but it needs the inputs set in a specific way
    //to do so we need to split the signature
    function recoverSigner(
        bytes32 getEthSignedMessageHash,
        bytes memory signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        return ecrecover(getEthSignedMessageHash, v, r, s);
    }

    function splitSignature(
        bytes memory sig
    ) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        //to split the signature we need to use assembly, all signatures are 65 bytes long, since two r and s are always 32 bytes, and v is 1 byte
        require(sig.length == 65, "invalid signature length");

        assembly {
            //signature
            //        0x {32bytes of signature length} + {32bytes of r} + {32 bytes of s} + {1 byte of v}

            // we save in r:
            //load from memory 32bytes starting at position X
            //sig represents a pointer to the start of signature, but the first 32 bytes is the length of the total signature
            //therefore we add 32 to sig to skip directly to the beginning of r
            //we then load 32 bytes in that new position
            r := mload(add(sig, 32))
            //we already skipped the signature length, so the next 32 bytes after r is s
            //therefore we add 32 more bytes to the previous position and we load the next 32 bytes

            s := mload(add(sig, 64))
            //since we only need the first byte we surround with type byte() and we state that we want the byte in the 0 position
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
