const DataAccessSystem = artifacts.require("DataAccessSystem");
const OrganizationManager = artifacts.require("OrganizationManager");

module.exports = async function (deployer) {
  const systemFeePercentage = 10; // 10% fee
  await deployer.deploy(DataAccessSystem, OrganizationManager.address, systemFeePercentage);
};
