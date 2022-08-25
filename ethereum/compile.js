const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');

const buildPath = path.resolve(__dirname, 'build');
fs.removeSync(buildPath);

const campaignPath = path.resolve(__dirname, 'contracts', 'Campaign.sol');

const source = fs.readFileSync(campaignPath, 'utf8');

const input = {
    language: "Solidity",
    sources: {
        "Campaign.sol": {
            content: source,
        },
    },
    settings: {
        outputSelection: {
            "*": {
                "*": ["*"],
            },
        },
    },
};

//console.log('before output: ', JSON.parse(solc.compile(JSON.stringify(input))));
const output = JSON.parse(solc.compile(JSON.stringify(input))).contracts[
    "Campaign.sol"
];

//console.log(output);
fs.ensureDirSync(buildPath);

for (let contract in output) {
    //console.log(contract);
    fs.outputJsonSync(
        path.resolve(buildPath, contract.replace(":", "") + ".json"),
        output[contract]
    );
}

