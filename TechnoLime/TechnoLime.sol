// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
import "./Ownable.sol";
import "./Receiver.sol";

contract TechnoLimeStore is Ownable, Receiver {
    enum TechnoLime{lime_0, lime_1, lime_2, lime_3, lime_4}

    // Store Details
    mapping(TechnoLime => uint) public inventory;
    mapping(TechnoLime => uint) public prices;
    uint public constant RETURN_PERIOD = 100;

    // Clients details
    mapping(address => bool) public isClient;
    address[] public clients;
    mapping(address => mapping(TechnoLime => uint)) public ledger; // {Client:{TechnoLime:Holding}}
    mapping(address => TechnoLime[]) public clientsLimes; 
    mapping(address => mapping(TechnoLime => uint)) public transactionBlocks;
    mapping(address => mapping(TechnoLime => uint)) public transactionPrices;

    // Events
    event PriceUpdateLog(address indexed _sender, TechnoLime _lime, uint _price);
    event LimeAddedLog(address indexed _sender, TechnoLime _lime, uint _qty);
    event LimeRemovedLog(address indexed _sender, TechnoLime _lime, uint _qty);
    event LimeBuyLog(address indexed _sender, TechnoLime _lime, uint _qty);
    event LimeReturnLog(address indexed _sender, TechnoLime _lime, uint _qty);

    // Constructor
    constructor() payable {}

    // Store owner functions
    function addLime(TechnoLime lime, uint qty) external onlyOwner {
        require(prices[lime]>0, "Please update price first!");
        inventory[lime] += qty;
        emit LimeAddedLog(msg.sender, lime, qty);
    }

    function removeLime(TechnoLime lime, uint qty) external onlyOwner {
        require(inventory[lime] >= qty, "not enough inventory");
        inventory[lime] -= qty;
        emit LimeRemovedLog(msg.sender, lime, qty);
    }

    function updatePrice(TechnoLime lime, uint price) external onlyOwner {
        prices[lime] = price;
        emit PriceUpdateLog(msg.sender, lime, price); // msg.sender used instead of owner for small gas optimization
    }

    // Clients functions
    function buyLime(TechnoLime lime, uint qty) external payable {
        // check qty > 0
        require(qty>0, "quantity to buy needs to be strictly higher than 0");

        // check enough inventory
        require(qty<inventory[lime], "not enough inventory in store");

        // Check enough ETH is sent
        require(msg.value > prices[lime] * qty, "not enough ETH is sent");

        // Check client never bought the product before
        TechnoLime[] memory clientLimes = clientsLimes[msg.sender];
        for (uint i=0; i<clientLimes.length; i++){
            if(clientLimes[i] == lime) {
                revert("TechnoLime already bought by Client");
            }
        }
        
        // Update transactionBlocks
        transactionBlocks[msg.sender][lime] = block.number;

        // Update ledger
        ledger[msg.sender][lime] = qty;

        // Update clientsLimes
        clientsLimes[msg.sender].push(lime);

        // Update clients list
        if(!isClient[msg.sender]){
            isClient[msg.sender] = true;
            clients.push(msg.sender);
        }

        // Update transactionPrices
        transactionPrices[msg.sender][lime] = prices[lime];

        // Update inventory
        inventory[lime] -= qty;

        // Log Event
        emit LimeBuyLog(msg.sender, lime, qty);
    }

    function returnLime(TechnoLime lime) external {
        address _client = msg.sender;
        uint _holding = ledger[_client][lime];
        require (_holding>0, "No holding to return to store");
        
        // Check client bought the product less than RETURN_PERIOD block ago
        if (transactionBlocks[_client][lime] != 0){
            require(transactionBlocks[_client][lime] + RETURN_PERIOD > block.number, "Too late to return TechnoLime");
        }

        // Pay back to client
        uint _amount = _holding * transactionPrices[_client][lime];
        (bool sent, ) = payable(_client).call{value: _amount}("");
        require(sent, "Failed to send Ether");

        // Update inventory
        inventory[lime] += _holding;

        // Reset client records => as if no transaction took place
        ledger[_client][lime] = 0;
        transactionPrices[_client][lime] = 0;
        transactionBlocks[_client][lime] = 0;

        // Log Event
        emit LimeReturnLog(msg.sender, lime, _holding);
    }
}