var RoleManager = artifacts.require("./RoleManager.sol");
var SupplyChain = artifacts.require("./SupplyChain.sol");

module.exports = function(deployer) {
   deployer.deploy(RoleManager);
   deployer.deploy(SupplyChain);
};
