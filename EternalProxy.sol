//SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

//This model secures no hash collisions when changing implementations by separating logic from state,
//The eternal storage holds all storage variables in the storage slots of the hashed variable names.abi
//We also create a parallel mapping that indicates if the value has been set or not for that hash.
contract EternalStorage {
    //values will be stored in the keccak256 of the name of the function to secure against hash collisions
    mapping(bytes32 => uint) UIntStorage;

    function getUIntValue(bytes32 record) public view returns (uint) {
        return UIntStorage[record];
    }

    function setUIntValue(bytes32 record, uint value) public {
        UIntStorage[record] = value;
    }

    mapping(bytes32 => bool) BooleanStorage;

    function getBooleanValue(bytes32 record) public view returns (bool) {
        return BooleanStorage[record];
    }

    function setBooleanValue(bytes32 record, bool value) public {
        BooleanStorage[record] = value;
    }
}

library ballotLib {
    function getNumberOfVotes(
        address _eternalStorage
    ) public view returns (uint256) {
        return EternalStorage(_eternalStorage).getUIntValue(keccak256("votes"));
    }

    function getUserHasVoted(
        address _eternalStorage
    ) public view returns (bool) {
        return
            EternalStorage(_eternalStorage).getBooleanValue(
                keccak256(abi.encodePacked("voted", msg.sender))
            );
    }

    function setUserHasVoted(address _eternalStorage) public {
        EternalStorage(_eternalStorage).setBooleanValue(
            keccak256(abi.encodePacked("voted", msg.sender)),
            true
        );
    }

    function setVoteCount(address _eternalStorage, uint _voteCount) public {
        EternalStorage(_eternalStorage).setUIntValue(
            keccak256("votes"),
            _voteCount
        );
    }
}

contract Ballot {
    using ballotLib for address;
    address eternalStorage;

    constructor(address _eternalStorage) {
        eternalStorage = _eternalStorage;
    }

    function getNumberOfVotes() public view returns (uint) {
        return eternalStorage.getNumberOfVotes();
    }

    function vote() public {
        require(
            eternalStorage.getUserHasVoted() == false,
            "ERR_USER_ALREADY_VOTED"
        );
        eternalStorage.setUserHasVoted();
        eternalStorage.setVoteCount(eternalStorage.getNumberOfVotes() + 1);
    }
}
