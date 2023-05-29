pragma solidity ^0.8.19;

import "./RoleManager.sol";

contract SupplyChain is RoleManager {
    uint uniqueIdentifier;

    enum State {
        Created,
        Transit,
        Purchased
    }

    State constant defaultState = State.Created;

    struct Item {
        uint ean;
        uint id;
        address payable creatorId;
        address payable currentOwnerId;
        // Created ( creatorId == currentOwnerId)
        // Transit (creatorId)
        string factoryName;
        uint productPrice;
        State state;
    }

    mapping(uint => Item) items;

    event ItemCreated(uint id);
    event Transit(uint id, address indexed toOwnerId);
    event Purchsed(uint id, address indexed toOwnerId);

    modifier verifyCaller(address _address) {
        require(
            msg.sender == _address,
            "This account is not the owner of this item"
        );
        _;
    }

    modifier paidEnough(uint _price) {
        require(
            msg.value >= _price,
            "The amount sent is not sufficient for the price"
        );
        _;
    }

    modifier notSold(uint id) {
        require(
            items[id].state == State.Created ||
                items[id].state == State.Transit,
            "The Item is not in Created state!"
        );
        _;
    }

    modifier transit(uint id) {
        require(
            items[id].state == State.Transit,
            "The Item is not in transit state!"
        );
        _;
    }

    modifier purchased(uint _upc) {
        require(
            items[_upc].state == State.Purchased,
            "The Item is not in Purchased state!"
        );
        _;
    }

    constructor() public payable {
        uniqueIdentifier = 1;
        createRole("creator");
        createRole("distributor");
        createRole("customer");
    }

    // allows a creator to mark an item 'Created'
    function createItem(
        uint _ean,
        uint productPrice,
        string memory _factoryName
    ) public {
        address payable _creatorId = payable(msg.sender);
        require(
            hasRole("creator", _creatorId),
            "This account has no a Creator Role"
        );
        Item memory item = Item({
            ean: _ean,
            id: uniqueIdentifier++,
            creatorId: _creatorId,
            currentOwnerId: _creatorId,
            factoryName: _factoryName,
            state: State.Created,
            productPrice: productPrice
        });
        items[item.id] = item;
        emit ItemCreated(uniqueIdentifier);
    }

    // Buy as distributor from Creator/ another distributor
    function buyTransit(uint _id) public payable notSold(_id) {
        uint productPrice = items[_id].productPrice;

        require(
            hasRole("distributor", msg.sender),
            "This account has no a Distributor Role"
        );
        require(
            msg.value >= productPrice,
            string.concat("The amount sent is not sufficient for the price")
        );
        // Transfer money to current owner
        items[_id].currentOwnerId.transfer(productPrice);

        items[_id].currentOwnerId = payable(msg.sender);
        items[_id].state = State.Transit;

        emit Transit(_id, msg.sender);
    }

    // Buy as distributor from Creator/ another distributor
    function buyCustomer(uint _id) public payable notSold(_id) {
        uint productPrice = items[_id].productPrice;

        require(
            hasRole("customer", msg.sender),
            "This account has no a Customer Role"
        );
        require(
            msg.value >= productPrice,
            "The amount sent is not sufficient for the price"
        );
        // Transfer money to current owner
        items[_id].currentOwnerId.transfer(productPrice);

        items[_id].currentOwnerId = payable(msg.sender);
        items[_id].state = State.Transit;

        emit Transit(_id, msg.sender);
    }

    function changeProductPrice(uint _id, uint _newPrice) public {
        require(
            items[_id].currentOwnerId == msg.sender,
            "This account does not own this item"
        );
        items[_id].productPrice = _newPrice;
    }

    function getItem(
        uint _id
    )
        public
        view
        returns (
            uint ean,
            uint id,
            address creatorId,
            address currentOwnerId,
            string memory factoryName,
            uint productPrice,
            State state
        )
    {
        Item memory item = items[_id];
        return (
            item.ean,
            item.id,
            item.creatorId,
            item.currentOwnerId,
            item.factoryName,
            item.productPrice,
            item.state
        );
    }

    function itemExists(uint _id) public view returns (bool) {
        return items[_id].id != 0;
    }
}
