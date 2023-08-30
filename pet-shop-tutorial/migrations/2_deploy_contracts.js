var Adoption = artifacts.require("Adoption");
var CoffeeSupplyChain = artifacts.require("CoffeeSupplyChain");

module.exports = function (deployer) {
  deployer.deploy(Adoption);
    deployer.deploy(CoffeeSupplyChain);

};
