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
        State state;
    }

    mapping(uint => Item) items;

    event Created(uint id);
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

    modifier created(uint id) {
        require(
            items[id].state == State.Created,
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
        uniqueIdentifier = 0;
    }

    // Define a function 'createItem' that allows a creator to mark an item 'Created'
    function createItem(
        uint _ean,
        address payable _creatorId,
        string memory _factoryName
    ) public {
        require(
            hasRole("Creator", _creatorId),
            "This account has no a Creator Role"
        );
        Item memory item = Item({
            ean: _ean,
            id: uniqueIdentifier++,
            creatorId: _creatorId,
            currentOwnerId: _creatorId,
            factoryName: _factoryName,
            state: State.Created
        });
        items[item.id] = item;
        emit Created(uniqueIdentifier);
    }
}
