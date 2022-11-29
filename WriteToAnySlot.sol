// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


contract Storage {
    struct StorageStruct {
        uint value;
    }

    StorageStruct public storage0 = StorageStruct(1)
    StorageStruct public storage1 = StorageStruct(2)
    StorageStruct public storage2 = StorageStruct(3)


    //The first function returns the Struct that is saved on the slot number we ask for, 


    function assemblyGetStruct(uint slotNumber) internal pure returns (StorageStruct storage structFromSlotNumber) {

        assembly {
            structFromSlotNumber.slot := slotNumber
        }
        
    }

    //The second function returns the value after getting the Struct calling the first function
    function getValue(uint slotNumber) external view returns (uint) {

        return assemblyGetStruct(slotNumber).value;

    }

    function setValue(uint slotNumber, uint newValue) external {
        assemblyGetStruct(slotNumber).value = newValue;
    }

}
