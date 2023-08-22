pragma solidity ^0.5.0;

contract Marketplace {
    string public name;
    /** we need to keep track of the product amount of*/
    uint public productCount = 0;

    /**Place to store the key value of the structure */
    mapping(uint => Product) public products;

    /** item a user will sell */
    struct Product {
        uint id;
        string name;
        uint price;
        address payable owner;
        bool purchased;
    }

    event ProductCreated(
        uint id,
        string name,
        uint price,
        address payable owner,
        bool purchased
    );
        event ProductPurchased(
        uint id,
        string name,
        uint price,
        address payable owner,
        bool purchased
    );

    constructor() public {
        name = "Comp726 Coffee Blockchain app";
    }

    function createProduct(string memory _name, uint _price) public {
        //make sure parameters are correct

        //require a valid name
        require(bytes(_name).length > 0);
        //require a valid price
        require(_price > 0);

        //increment product count
        productCount++;
        // Create the product and add to mapping
        products[productCount] = Product(
            productCount,
            _name,
            _price,
            msg.sender,
            false
        );
        // Trigger an event
        emit ProductCreated(productCount, _name, _price, msg.sender, false);
    }

    function purchaseProduct(uint _id) public payable {
        //Fetch the produxct
        Product memory _product = products[_id];
        //fetch the owner
        address payable _seller = _product.owner;
        //make sure the product is valid
        require(_product.id > 0 &&_product.id <= productCount);
        //require that there is enough ether in the transactopm
        require(msg.value >= _product.price);
        //require that the product has not been purchased already
        require(!_product.purchased);
        //require that buyer is not sender
        require(_seller != msg.sender);

        //transfer ownership to the buyer
        _product.owner = msg.sender;
        //mark as purchaseds
        _product.purchased = true;
        //update produt
        products[_id] = _product;
        //pay seller by sending them eather
        address(_seller).transfer(msg.value);
        //trigger an event
        emit ProductPurchased(productCount, _product.name , _product.price, msg.sender, true);
    }
}
