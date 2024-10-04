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

    struct AccessRequest {
        address requester;
        uint256 amountPaid;
        bool approved;
    }

    mapping(uint256 => Dataset) public datasets;
    mapping(address => mapping(uint256 => uint256)) public accessExpiry; // user's access expiry for dataset
    mapping(uint256 => AccessRequest[]) public accessRequests; // datasetId => array of requests

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

    // User requests access
    function requestAccess(uint256 datasetId) public payable {
        Dataset memory dataset = datasets[datasetId];
        require(dataset.organization != address(0), "Dataset does not exist");
        require(msg.value >= dataset.pricePerDay, "Insufficient payment");

        accessRequests[datasetId].push(
            AccessRequest({
                requester: msg.sender,
                amountPaid: msg.value,
                approved: false
            })
        );

        emit AccessRequested(msg.sender, datasetId, msg.value);
    }

    // Organization approves access request
    function approveAccess(
        uint256 datasetId,
        address requester
    ) public onlyOrganization {
        Dataset memory dataset = datasets[datasetId];
        require(dataset.organization == msg.sender, "Not the dataset owner");

        AccessRequest[] storage requests = accessRequests[datasetId];
        for (uint256 i = 0; i < requests.length; i++) {
            if (requests[i].requester == requester && !requests[i].approved) {
                requests[i].approved = true;

                // Calculate fee and distribute funds
                uint256 systemFee = (requests[i].amountPaid *
                    systemFeePercentage) / 100;
                uint256 orgShare = requests[i].amountPaid - systemFee;

                payable(owner).transfer(systemFee);
                dataset.organization.transfer(orgShare);

                // Grant access
                uint256 daysPaid = requests[i].amountPaid / dataset.pricePerDay;
                uint256 expiryTime = block.timestamp + (daysPaid * 1 days);
                accessExpiry[requester][datasetId] = expiryTime;

                emit AccessGranted(requester, datasetId, expiryTime);
                break;
            }
        }
    }

    // Check access
    function hasAccess(
        address user,
        uint256 datasetId
    ) public view returns (bool) {
        return block.timestamp < accessExpiry[user][datasetId];
    }

    // Get metadata
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

    // Get access requests for a dataset (organization only)
    function getAccessRequests(
        uint256 datasetId
    ) public view onlyOrganization returns (AccessRequest[] memory) {
        Dataset memory dataset = datasets[datasetId];
        require(dataset.organization == msg.sender, "Not the dataset owner");
        return accessRequests[datasetId];
    }
}
