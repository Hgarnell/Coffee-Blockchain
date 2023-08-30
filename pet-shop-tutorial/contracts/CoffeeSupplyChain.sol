pragma solidity ^0.5.0;

contract CoffeeSupplyChain {
    address public owner;

    // Enum to represent different stages of the bean's journey
    enum BeanStatus {
        Harvested,
        Processed,
        Roasted,
        Packed,
        Shipped,
        Received
    }

    // Enum to represent different types of owners
    enum OwnerType {
        None,
        Grower,
        Distributor,
        Retailer,
        Processor,
        Exporter,
        Broker,
        Roaster
    }

    struct Bean {
        uint256 id;
        string growerName;
        uint256 harvestTimestamp;
        uint256 beanWeight; // Weight of beans in kilograms
        BeanStatus status;
        OwnerType ownerName;
    }

    mapping(uint256 => Bean) public beans;
    mapping(address => OwnerType) public ownerTypes;
    uint256 public beanCount;

    // restricts function to only be executed by the contract owner.
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can perform this action"
        );
        _;
    }
    // restricts function to only be executed by the contract owner if they meet a certain type
    modifier onlyOfType(OwnerType _ownerType) {
        require(
            ownerTypes[msg.sender] == _ownerType,
            "Only owners of the specified type can perform this action"
        );
        _;
    }
    event BeanHarvested(
        uint256 indexed beanId,
        string growerName,
        uint256 harvestTimestamp,
        uint256 beanWeight
    );
    event BeanProcessed(uint256 indexed beanId);
    event BeanPacked(uint256 indexed beanId);
    event BeanShipped(uint256 indexed beanId);
    event BeanReceived(uint256 indexed beanId);

    constructor() public {
        owner = msg.sender;
        beanCount = 0;
        ownerTypes[msg.sender] = OwnerType.None;
    }

    // Function to set the owner type
    function setOwnerType(OwnerType _ownerType) public {
        ownerTypes[msg.sender] = _ownerType;
    }

    // Function to harvest beans
    function harvestBean(
        string memory _growerName,
        uint256 _beanWeight
    ) public onlyOfType(OwnerType.Grower) {
        beanCount++;
        beans[beanCount] = Bean(
            beanCount,
            _growerName,
            block.timestamp,
            _beanWeight,
            BeanStatus.Harvested,
            OwnerType.Grower
        );
        emit BeanHarvested(
            beanCount,
            _growerName,
            block.timestamp,
            _beanWeight
        );
    }

    // Function to process beans
    function processBean(
        uint256 _beanId
    ) public onlyOfType(OwnerType.Processor) {
        require(
            beans[_beanId].status == BeanStatus.Harvested,
            "Bean has not been harvested yet"
        );
        beans[_beanId].status = BeanStatus.Processed;
        beans[_beanId].ownerName = OwnerType.Processor;

        emit BeanProcessed(_beanId);
    }

    // Function to process beans
    function roastBean(uint256 _beanId) public onlyOfType(OwnerType.Roaster) {
        require(
            beans[_beanId].status == BeanStatus.Processed,
            "Bean has not been Processed yet"
        );
        beans[_beanId].status = BeanStatus.Roasted;
        beans[_beanId].ownerName = OwnerType.Roaster;

        emit BeanProcessed(_beanId);
    }

    // Function to pack beans
    function packBean(
        uint256 _beanId
    ) public onlyOfType(OwnerType.Distributor) {
        require(
            beans[_beanId].status == BeanStatus.Roasted,
            "Bean has not been Roasted yet"
        );
        beans[_beanId].status = BeanStatus.Packed;
        beans[_beanId].ownerName = OwnerType.Distributor;

        emit BeanPacked(_beanId);
    }

    // Function to ship beans
    function shipBean(
        uint256 _beanId
    ) public onlyOfType(OwnerType.Distributor) {
        require(
            beans[_beanId].status == BeanStatus.Packed,
            "Bean has not been packed yet"
        );
        beans[_beanId].status = BeanStatus.Shipped;
        emit BeanShipped(_beanId);
    }

    // Function to receive beans
    function receiveBean(
        uint256 _beanId
    ) public onlyOfType(OwnerType.Retailer) {
        require(
            beans[_beanId].status == BeanStatus.Shipped,
            "Bean has not been shipped yet"
        );
        beans[_beanId].status = BeanStatus.Received;
        emit BeanReceived(_beanId);
    }

    // Function to get the entire process of how the bean was transacted
    function getBeanProcess(
        uint256 _beanId
    ) public view returns (BeanStatus[] memory) {
        require(_beanId <= beanCount && _beanId > 0, "Invalid bean ID");

        BeanStatus[] memory process = new BeanStatus[](
            uint256(BeanStatus.Received) + 1
        );

        for (
            uint256 i = uint256(BeanStatus.Harvested);
            i <= uint256(BeanStatus.Received);
            i++
        ) {
            if (i == uint256(BeanStatus.Received)) {
                process[i] = beans[_beanId].status;
            } else {
                process[i] = BeanStatus(i);
            }
        }

        return process;
    }
}
