// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OrganizationManager.sol";

contract DataAccessSystem {
    address public owner;
    uint256 public systemFeePercentage; // e.g., 10 for 10%

    OrganizationManager public orgManager;

    struct Dataset {
        string name;
        string url;
        uint256 pricePerDay;
        address payable organization;
    }

    mapping(uint256 => Dataset) public datasets;
    mapping(address => mapping(uint256 => uint256)) public accessExpiry; // user's access expiry for dataset

    uint256 public datasetCount;

    event DatasetAdded(
        uint256 datasetId,
        string name,
        uint256 pricePerDay,
        address indexed organization
    );
    event AccessRequested(
        address indexed user,
        uint256 indexed datasetId,
        uint256 amountPaid
    );
    event AccessGranted(
        address indexed user,
        uint256 indexed datasetId,
        uint256 expiryTime
    );

    constructor(address _orgManagerAddress, uint256 _systemFeePercentage) {
        owner = msg.sender;
        orgManager = OrganizationManager(_orgManagerAddress);
        systemFeePercentage = _systemFeePercentage;
    }

    modifier onlyOrganization() {
        require(
            orgManager.isOrganization(msg.sender),
            "Not a registered organization"
        );
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // Organization adds a dataset
    function addDataset(
        string memory name,
        string memory url,
        uint256 pricePerDay
    ) public onlyOrganization {
        datasetCount++;
        datasets[datasetCount] = Dataset(
            name,
            url,
            pricePerDay,
            payable(msg.sender)
        );
        emit DatasetAdded(datasetCount, name, pricePerDay, msg.sender);
    }

    // User requests access and gets access immediately after payment
    function requestAccess(uint256 datasetId) public payable {
        Dataset memory dataset = datasets[datasetId];
        require(dataset.organization != address(0), "Dataset does not exist");
        require(msg.value >= dataset.pricePerDay, "Insufficient payment");

        // Calculate fee and distribute funds
        uint256 systemFee = (msg.value * systemFeePercentage) / 100;
        uint256 orgShare = msg.value - systemFee;

        // Transfer funds
        payable(owner).transfer(systemFee);
        dataset.organization.transfer(orgShare);

        // Grant access
        uint256 daysPaid = msg.value / dataset.pricePerDay;
        uint256 expiryTime = block.timestamp + (daysPaid * 1 days);
        accessExpiry[msg.sender][datasetId] = expiryTime;

        // Emit events
        emit AccessRequested(msg.sender, datasetId, msg.value);
        emit AccessGranted(msg.sender, datasetId, expiryTime);
    }

    // Check if the user has access to the dataset
    function hasAccess(
        address user,
        uint256 datasetId
    ) public view returns (bool) {
        return block.timestamp < accessExpiry[user][datasetId];
    }

    // Get dataset metadata
    function getMetadata(
        uint256 datasetId
    ) public view returns (string memory, string memory, uint256, address) {
        Dataset memory dataset = datasets[datasetId];
        return (
            dataset.name,
            dataset.url,
            dataset.pricePerDay,
            dataset.organization
        );
    }
}
