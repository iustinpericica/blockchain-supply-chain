pragma solidity ^0.8.19;

// Declare a contract for managing roles
contract RoleManager {
    // Declare a struct for storing a role
    struct Role {
        bool exists;
        mapping(address => bool) members;
    }

    // Declare a map for storing roles
    mapping(string => Role) roles;

    // Event emitted when a role is added
    event RoleAdded(string indexed roleName);

    event AddressAddedToRole(string indexed roleName, address indexed member);

    event AddressRemovedFromRole(
        string indexed roleName,
        address indexed member
    );

    constructor() public {
        // Create a role for the contract owner
    }

    // Add a member to a role
    function addMember(string memory roleName, address member) public {
        // Only member of the role group can add a member to that group
        require(hasRole(roleName, msg.sender), "Sender is not authorized");
        _addMember(roleName, member);
    }

    function _addMember(string memory roleName, address member) internal {
        Role storage role = roles[roleName];
        require(role.exists, "Role does not exist");

        role.members[member] = true;
        emit AddressAddedToRole(roleName, member);
    }

    // Remove a member from a role
    function removeMember(string memory roleName, address member) public {
        Role storage role = roles[roleName];
        require(role.exists, "Role does not exist");

        delete role.members[member];
        emit AddressRemovedFromRole(roleName, member);
    }

    // Check if an address belongs to a role
    function hasRole(
        string memory roleName,
        address member
    ) public view returns (bool) {
        Role storage role = roles[roleName];
        require(role.exists, "Role does not exist");

        return role.members[member];
    }

    // Create a new role
    function createRole(string memory roleName) public {
        Role storage role = roles[roleName];
        require(!role.exists, "Role already exists");

        role.exists = true;

        // who created the role is the first member
        _addMember(roleName, msg.sender);
        emit RoleAdded(roleName);
    }

    // Role exists
    function roleExists(string memory roleName) public view returns (bool) {
        Role storage role = roles[roleName];
        return role.exists;
    }
}
