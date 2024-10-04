const OrganizationManager = artifacts.require("OrganizationManager");

module.exports = function (deployer) {
    deployer.deploy(OrganizationManager);
};
