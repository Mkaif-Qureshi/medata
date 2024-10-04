import web3 from '../src/utils/web3';

const address = '0x1c0e2f952c39120dd3ce34bd5ec52c76f5d7b69c';
const abi = [
    {
        "inputs": [],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "orgAddress",
                "type": "address"
            }
        ],
        "name": "OrganizationRegistered",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "orgAddress",
                "type": "address"
            }
        ],
        "name": "OrganizationRemoved",
        "type": "event"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "orgAddress",
                "type": "address"
            }
        ],
        "name": "isOrganization",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "name": "organizations",
        "outputs": [
            {
                "internalType": "bool",
                "name": "",
                "type": "bool"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "owner",
        "outputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "orgAddress",
                "type": "address"
            }
        ],
        "name": "registerOrganization",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "orgAddress",
                "type": "address"
            }
        ],
        "name": "removeOrganization",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    }
];
export default new web3.eth.Contract(abi, address);
