var RoleManager = artifacts.require("RoleManager");
const truffleAssert = require('truffle-assertions');

contract('Role', function(accounts) {
    var roleManager;

    before(async () => {
        roleManager = await RoleManager.deployed();
    });

    it("should create a new role", async () => {
        var txCreateRole = await roleManager.createRole("admin");
        var res = await roleManager.roleExists("admin");
        assert.equal(res, true);
        truffleAssert.eventEmitted(txCreateRole, 'RoleAdded');
    });

    it("should add a user to a role", async () => {
        var txAddMember = await roleManager.addMember("admin", accounts[0]);
        var res = await roleManager.hasRole("admin", accounts[0]);
        assert.equal(res, true);
        truffleAssert.eventEmitted(txAddMember, 'AddressAddedToRole');
    });

    it("should remove a user from a role", async () => {
        var txRemoveMember = await roleManager.removeMember("admin", accounts[0]);
        var res = await roleManager.hasRole("admin", accounts[0]);
        assert.equal(res, false);
        truffleAssert.eventEmitted(txRemoveMember, 'AddressRemovedFromRole');
    });
    
    it("should throw error when adding a user to a non-existent role", async () => {
        try {
            await roleManager.addMember("non-existent-role", accounts[0]);
        } catch (error) {
            assert.equal(error.reason, "Role does not exist");
        }
    });
});