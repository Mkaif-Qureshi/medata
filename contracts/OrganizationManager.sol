// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OrganizationManager {
    address public owner;
    mapping(address => bool) public organizations;

    event OrganizationRegistered(address indexed orgAddress);
    event OrganizationRemoved(address indexed orgAddress);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute");
        _;
    }

    // Register an organization
    function registerOrganization(address orgAddress) public onlyOwner {
        organizations[orgAddress] = true;
        emit OrganizationRegistered(orgAddress);
    }

    // Remove an organization
    function removeOrganization(address orgAddress) public onlyOwner {
        organizations[orgAddress] = false;
        emit OrganizationRemoved(orgAddress);
    }

    // Check if an address is an organization
    function isOrganization(address orgAddress) public view returns (bool) {
        return organizations[orgAddress];
    }
}
