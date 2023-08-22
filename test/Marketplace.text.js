const Marketplace = artifacts.require("./Marketplace.sol");

require("chai")
  .use(require("chai-as-promised"))
  .should();

contract("Marketplace", ([deployer, seller, buyer]) => {
  let marketplace;

  before(async () => {
    marketplace = await Marketplace.deployed();
  });

  describe("deployment", async () => {
    it("deploys successfully", async () => {
      const address = await marketplace.address;
      assert.notEqual(address, 0x0);
      assert.notEqual(address, "");
      assert.notEqual(address, null);
      assert.notEqual(address, undefined);
    });

    it("has a name", async () => {
      const name = await marketplace.name();
      assert.equal(name, "Comp726 Coffee Blockchain app");
    });
  });

  /**testing for products creation*/
  describe("products", async () => {
    let result, productCount;

    before(async () => {
      /**funxction metadata to say its from seller */
      result = await marketplace.createProduct("Coffee Beans", web3.utils.toWei("1", "Ether"), { from: seller });
      productCount = await marketplace.productCount();
    });

    it("creates products", async () => {
      //success
      assert.equal(productCount, 1);
      const event = result.logs[0].args;
      assert.equal(event.id.toNumber(), productCount.toNumber(), "id is correct");
      assert.equal(event.name, "Coffee Beans", "name is correct");
      assert.equal(event.price, "1000000000000000000", "price is correct");
      assert.equal(event.owner, seller, "owner is correct");
      assert.equal(event.purchased, false, "purchased is correct");
      //failure testing: product must have name
      await await marketplace.createProduct("", web3.utils.toWei("1", "Ether"), { from: seller }).should.be.rejected;
      //failure: product must have a price
      await await marketplace.createProduct("iPhone X", 0, { from: seller }).should.be.rejected;
    });

    it("Sells Products", async () => {
                           //track the old seller balance before purchase
                           let oldSellerBalance;
                           oldSellerBalance = await web3.eth.getBalance(seller);
                           oldSellerBalance = new web3.utils.BN(oldSellerBalance);

                           //Success: Buyer makes purchase
                           result = await marketplace.purchaseProduct(productCount, { from: buyer, value: web3.utils.toWei("1", "Ether") });

                           //check logs
                           //
                           const event = result.logs[0].args;
                           assert.equal(event.id.toNumber(), productCount.toNumber(), "id is correct");
                           assert.equal(event.name, "Coffee Beans", "name is correct");
                           assert.equal(event.price, "1000000000000000000", "price is correct");
                           assert.equal(event.owner, buyer, "owner is correct");
                           assert.equal(event.purchased, true, "purchased is correct");

                           //chheck seller recieved funds
                           let newSellerBalance;
                           newSellerBalance = await web3.eth.getBalance(seller);
                           newSellerBalance = new web3.utils.BN(newSellerBalance);

                           let price;
                           price = web3.utils.toWei("1", "Ether");
                           price = new web3.utils.BN(price);

                           const expectedBalance = oldSellerBalance.add(price);

                           assert.equal(newSellerBalance.toString(), expectedBalance.toString());
                           //CFailure tries to buy a product trhat does not ezxist
                           await marketplace.purchaseProduct(99, { from: buyer, value: web3.utils.toWei("1", "Ether") }).should.be.rejected; // FAILURE: Buyer tries to buy without enough ether
                           //Failure buyer tries to buy wuthout enough ether
                             await marketplace.purchaseProduct(productCount, { from: buyer, value: web3.utils.toWei('0.5', 'Ether') }).should.be.rejected;
                           //Failure: deployer tries to buy the product
                             await marketplace.purchaseProduct(productCount, { from: deployer, value: web3.utils.toWei('1', 'Ether') }).should.be.rejected;

                           //Failure BUyer tries to buy again
                             await marketplace.purchaseProduct(productCount, { from: buyer, value: web3.utils.toWei('1', 'Ether') }).should.be.rejected;

                         });
  });
});
