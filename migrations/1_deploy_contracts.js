var RoleManager = artifacts.require("./RoleManager.sol");

module.exports = function(deployer) {
   deployer.deploy(RoleManager);
};
