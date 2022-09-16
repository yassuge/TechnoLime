// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
import "./Ownable.sol";
import "./Receiver.sol";
import "./TechnoLime.sol";

contract TechnoLimeStore is Ownable, Receiver {

    // Store Details
    mapping(string => uint) public inventory;
    mapping(string => uint) public prices;
    uint public constant RETURN_PERIOD = 100;

    // Clients details
    mapping(address => bool) public isClient;
    address[] public clients;
    mapping(address => mapping(string => uint)) public ledger; // {client:{id:holding}}
    mapping(address => TechnoLime[]) public clientsLimes; 
    mapping(address => mapping(string => uint)) public transactionBlocks;
    mapping(address => mapping(string => uint)) public transactionPrices;

    // Events
    event PriceUpdateLog(address indexed _sender, address indexed _lime, uint _price);
    event LimeAddedLog(address indexed _sender, address indexed _lime, uint _qty);
    event LimeRemovedLog(address indexed _sender, address indexed _lime, uint _qty);
    event LimeBuyLog(address indexed _sender, address indexed _lime, uint _qty);
    event LimeReturnLog(address indexed _sender, address indexed _lime, uint _qty);

    // Constructor
    constructor() payable {}

    // Store owner functions
    function addLime(TechnoLime lime, uint qty) external onlyOwner {
        string memory _id = lime.id();
        require(prices[_id] > 0, "Please update price first!");
        inventory[_id] += qty;
        emit LimeAddedLog(msg.sender, address(lime), qty);
    }

    function removeLime(TechnoLime lime, uint qty) external onlyOwner {
        string memory _id = lime.id();

        require(inventory[_id] >= qty, "not enough inventory");
        inventory[_id] -= qty;
        emit LimeRemovedLog(msg.sender, address(lime), qty);
    }

    function updatePrice(TechnoLime lime, uint price) external onlyOwner {
        string memory _id = lime.id();

        prices[_id] = price;
        emit PriceUpdateLog(msg.sender, address(lime), price); // msg.sender used instead of owner for small gas optimization
    }

    // Clients functions
    function buyLime(TechnoLime lime, uint qty) external payable {
        // check qty > 0
        require(qty>0, "quantity to buy needs to be strictly higher than 0");

        string memory _id = lime.id();

        // check enough inventory
        require(qty<inventory[_id], "not enough inventory in store");

        // Check enough ETH is sent
        require(msg.value > prices[_id] * qty, "not enough ETH is sent");

        // Check client never bought the product before
        TechnoLime[] memory clientLimes = clientsLimes[msg.sender];
        for (uint i=0; i<clientLimes.length; i++){
            if(clientLimes[i] == lime) {
                revert("TechnoLime already bought by Client");
            }
        }
        
        // Update transactionBlocks
        transactionBlocks[msg.sender][_id] = block.number;

        // Update ledger
        ledger[msg.sender][_id] = qty;

        // Update clientsLimes
        clientsLimes[msg.sender].push(lime);

        // Update clients list
        if(!isClient[msg.sender]){
            isClient[msg.sender] = true;
            clients.push(msg.sender);
        }

        // Update transactionPrices
        transactionPrices[msg.sender][_id] = prices[_id];

        // Update inventory
        inventory[_id] -= qty;

        // Log Event
        emit LimeBuyLog(msg.sender, address(lime), qty);
    }

    function returnLime(TechnoLime lime) external {
        address _client = msg.sender;
        string memory _id = lime.id();
        uint _holding = ledger[_client][_id];
        require (_holding>0, "No holding to return to store");
        
        // Check client bought the product less than RETURN_PERIOD block ago
        if (transactionBlocks[_client][_id] != 0){
            require(transactionBlocks[_client][_id] + RETURN_PERIOD > block.number, "Sorry! Too late to return TechnoLime");
        }

        // Pay back to client
        uint _amount = _holding * transactionPrices[_client][_id];
        (bool sent, ) = payable(_client).call{value: _amount}("");
        require(sent, "Failed to send Ether");

        // Update inventory
        inventory[_id] += _holding;

        // Reset client records => as if no transaction took place
        ledger[_client][_id] = 0;
        transactionPrices[_client][_id] = 0;
        transactionBlocks[_client][_id] = 0;

        // Log Event
        emit LimeReturnLog(msg.sender, address(lime), _holding);
    }
}