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
        address owner;
        bool purchased;
    }

    event ProductCreated(
        uint id,
        string name,
        uint price,
        address owner,
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
}
