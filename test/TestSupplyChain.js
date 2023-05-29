var SupplyChain = artifacts.require("SupplyChain");
const truffleAssert = require('truffle-assertions');

contract('SupplyChain', function(accounts) {
    var supplyChain;

    before(async () => {
        supplyChain = await SupplyChain.deployed();
        supplyChain.addMember("distributor", accounts[1]);
        supplyChain.addMember("distributor", accounts[2]);
        supplyChain.addMember("distributor", accounts[3]);
        supplyChain.addMember("customer", accounts[5]);
    });

    it("should create a new role", async () => {
        var txCreateRole = await supplyChain.createRole("admin");
        var res = await supplyChain.roleExists("admin");
        assert.equal(res, true);
        truffleAssert.eventEmitted(txCreateRole, 'RoleAdded');
    });
    
    it("should throw error when adding a user to a non-existent role", async () => {
        try {
            await supplyChain.addMember("non-existent-role", accounts[0]);
        } catch (error) {
            assert.equal(error.reason, "Role does not exist");
        }
    });

    it("should create item", async () => {
        var txCreateItem = await supplyChain.createItem(12345, 50, "Elmaro");
        var res = await supplyChain.itemExists(1);
        assert.equal(res, true);
        truffleAssert.eventEmitted(txCreateItem, 'ItemCreated');
    });

    it("should create second item", async () => {
        var txCreateItem = await supplyChain.createItem(12345, 50, "Elmaro");
        var res = await supplyChain.itemExists(2);
        var item = await supplyChain.getItem(2);
        assert.equal(item[0], 12345);
        assert.equal(item[1], 2);
        assert.equal(item[5], 50);
        assert.equal(res, true);
        truffleAssert.eventEmitted(txCreateItem, 'ItemCreated');
    });

    it("should buy item as transit: verify transfer of ownership & balance", async () => {
        var txCreateItem = await supplyChain.createItem(12345, 50, "Elmaro");
        const newItemId = 4;
        const buyerAccount = accounts[3];
        let buyerBalanceBeforePurchase = await web3.eth.getBalance(buyerAccount);

        var txBuyItem = await supplyChain.buyTransit(newItemId, {from: buyerAccount});
        let buyerBalanceAfterPurchase = await web3.eth.getBalance(buyerAccount);
        
        var item = await supplyChain.getItem(newItemId);
        assert(item[3], buyerAccount);
        assert(buyerBalanceBeforePurchase - item[5], buyerBalanceAfterPurchase);
        truffleAssert.eventEmitted(txBuyItem, 'Transit');
    });

});