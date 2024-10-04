import React, { useState, useEffect } from 'react';
import web3 from './utils/web3';
import organizationManager from '../contracts/OrganizationManager';
import dataAccessSystem from '../contracts/DataAccessSystem';

const App = () => {
  const [account, setAccount] = useState('');
  const [accountType, setAccountType] = useState('user'); // Default is user
  const [balance, setBalance] = useState(0);
  const [datasets, setDatasets] = useState([]);
  const [days, setDays] = useState(1);
  const [accessStatuses, setAccessStatuses] = useState({}); // Store access status for each dataset

  useEffect(() => {
    const load = async () => {
      const accounts = await web3.eth.getAccounts();
      setAccount(accounts[0]);

      // Get balance of the account
      const accountBalance = await web3.eth.getBalance(accounts[0]);
      setBalance(web3.utils.fromWei(accountBalance, 'ether'));

      // Determine if the account is an organization, manager, or user
      const isOrganization = await organizationManager.methods.isOrganization(accounts[0]).call();
      const isManager = (await organizationManager.methods.owner().call()) === accounts[0];

      if (isManager) {
        setAccountType('manager');
      } else if (isOrganization) {
        setAccountType('organization');
      } else {
        setAccountType('user');
      }

      // Load datasets
      const datasetCount = await dataAccessSystem.methods.datasetCount().call();
      const allDatasets = [];
      for (let i = 1; i <= datasetCount; i++) {
        const dataset = await dataAccessSystem.methods.getMetadata(i).call();
        allDatasets.push(dataset);

        // Check access for each dataset
        const hasAccess = await dataAccessSystem.methods.hasAccess(accounts[0], i).call();
        setAccessStatuses((prevStatuses) => ({
          ...prevStatuses,
          [i]: hasAccess,
        }));
      }
      setDatasets(allDatasets);
    };

    load().catch((err) => {
      console.error('Error loading datasets:', err);
    });
  }, []);

  const requestAccess = async (id, pricePerDay) => {
    const totalPrice = BigInt(pricePerDay) * BigInt(days);
    await dataAccessSystem.methods.requestAccess(id).send({
      from: account,
      value: totalPrice.toString(),
    });

    // After requesting access, update access status
    const hasAccess = await dataAccessSystem.methods.hasAccess(account, id).call();
    setAccessStatuses((prevStatuses) => ({
      ...prevStatuses,
      [id]: hasAccess,
    }));
  };

  const addDataset = async (name, url, pricePerDay) => {
    await dataAccessSystem.methods.addDataset(name, url, pricePerDay).send({ from: account });
  };

  // UI for different account types
  return (
    <div>
      <h1>Data Access System</h1>
      <p>Account: {account}</p>
      <p>Balance: {balance} ETH</p>
      <p>Type: {accountType.charAt(0).toUpperCase() + accountType.slice(1)}</p>

      {accountType === 'user' && (
        <div>
          <h2>Available Datasets</h2>
          {datasets.length > 0 ? (
            datasets.map((dataset, idx) => (
              <div key={idx}>
                <p>Name: {dataset[0]}</p>
                <p>Price per Day: {web3.utils.fromWei(dataset[2], 'ether')} ETH</p>
                <p>
                  Access Status:{' '}
                  {accessStatuses[idx + 1] ? 'Granted' : 'Not Granted'}
                </p>
                {!accessStatuses[idx + 1] && (
                  <button onClick={() => requestAccess(idx + 1, dataset[2])}>
                    Request Access for {days} day(s)
                  </button>
                )}
              </div>
            ))
          ) : (
            <p>No datasets available.</p>
          )}
          <input
            type="number"
            value={days}
            onChange={(e) => setDays(e.target.value)}
            placeholder="Number of Days"
          />
        </div>
      )}

      {accountType === 'organization' && (
        <div>
          <h2>Add New Dataset</h2>
          <input type="text" placeholder="Dataset Name" id="datasetName" />
          <input type="text" placeholder="Dataset URL" id="datasetUrl" />
          <input type="number" placeholder="Price per Day (ETH)" id="datasetPrice" />
          <button
            onClick={() =>
              addDataset(
                document.getElementById('datasetName').value,
                document.getElementById('datasetUrl').value,
                web3.utils.toWei(document.getElementById('datasetPrice').value, 'ether')
              )
            }
          >
            Add Dataset
          </button>

          <h2>Your Datasets</h2>
          {datasets.length > 0 ? (
            datasets
              .filter((d) => d[3] === account) // Show only datasets added by this organization
              .map((dataset, idx) => (
                <div key={idx}>
                  <p>Name: {dataset[0]}</p>
                  <p>URL: {dataset[1]}</p>
                  <p>Price per Day: {web3.utils.fromWei(dataset[2], 'ether')} ETH</p>
                </div>
              ))
          ) : (
            <p>No datasets available.</p>
          )}
        </div>
      )}

      {accountType === 'manager' && (
        <div>
          <h2>Manage System</h2>
          <p>As a manager, you can monitor transactions, system fees, etc.</p>
          {/* Add manager-specific functionalities here */}
        </div>
      )}
    </div>
  );
};

export default App;
