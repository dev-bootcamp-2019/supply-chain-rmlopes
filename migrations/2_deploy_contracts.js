var SupplyChain = artifacts.require("./SupplyChain.sol");
var SupplyChainWrapper = artifacts.require("./SupplyChainWrapper.sol");

module.exports = function(deployer) {
  deployer.deploy(SupplyChain);
  deployer.deploy(SupplyChainWrapper);
};
