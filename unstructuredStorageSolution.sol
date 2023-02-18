//Solution to common proxy/logic storage colisions in upgradeable smart contracts

//We can ignore the order of state variables declared on the implementation(upgradeable logic) because we dont follow the "classic" storage layout on our proxy contract
//where variables are stored in storage slot 0, following the layout rules described in the SOlidity documentation. 

//Instead, we allocate the proxy contract variables in specific positions where we know they arent going to collide with any new variables
//described in the implementations through the use of assembly.

contract OwnedUpgradeabilityProxy is Proxy { 

//getting a deterministic position for the locations of each variable stored as a constant(in contract bytecode constant variables are replaced for the actual value,therefore they dont occupy storage slots)
    bytes32 private constant ownerPosition = keccak256("org.zeppelinos.proxy.owner"); 
    bytes32 private constant implementationPosition = keccak256("org.zeppelinos.proxy.implementation"); 
    function upgradeTo(address newImplementation) public onlyProxyOwner {   
        address currentImplementation = implementation();   
        setImplementation(newImplementation); 
    } 
    function implementation() public view returns(address impl) {   
        bytes32 position = implementationPosition;   
        //we read the implementation address on position "keccak256("org.zeppelinos.proxy.implementation")"
        assembly {
            impl: = sload(position)
        } 
    } 
    function setImplementation(address newImplementation) internal {   
        bytes32 position = implementationPosition;   
        //we write the new implementation address on position "keccak256("org.zeppelinos.proxy.implementation")"
        assembly {
            sstore(position, newImplementation)
        } 
    } 
    function proxyOwner() public view returns(address owner) {   
        bytes32 position = proxyOwnerPosition; 
        //we read the owner address on position keccak256("org.zeppelinos.proxy.owner")"
        assembly {
            owner: = sload(position)
        } 
    } 
    function setUpgradeabilityOwner(address newProxyOwner) internal {   
        bytes32 position = proxyOwnerPosition;
        //we write the new owner address on position keccak256("org.zeppelinos.proxy.owner")"
        assembly {
            sstore(position, newProxyOwner)
   }
