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

    // Add a member to a role
    function addMember(string memory roleName, address member) public {
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
        emit RoleAdded(roleName);
    }

    // Role exists
    function roleExists(string memory roleName) public view returns (bool) {
        Role storage role = roles[roleName];
        return role.exists;
    }
}
