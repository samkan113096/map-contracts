require('hardhat-gas-reporter');
require('hardhat-spdx-license-identifier');
require('hardhat-deploy');
require('hardhat-abi-exporter');
require('@nomiclabs/hardhat-ethers');
require('dotenv/config');
require('@nomiclabs/hardhat-etherscan');
require('hardhat-contract-sizer');
require("hardhat-log-remover");
require("./tasks")


const { PRIVATE_KEY, INFURA_KEY} = process.env;


let accounts = [];

accounts.push(PRIVATE_KEY);


module.exports = {
  defaultNetwork: 'hardhat',
  abiExporter: {
    path: './abi',
    clear: false,
    flat: true,
  },
  networks: {
    hardhat: {
      forking: {
        enabled: false,
        //url: `https://bsctest.pls2e.cc`,
        url: `https://data-seed-prebsc-1-s1.binance.org:8545`,
        //url: `https://bsc-dataseed.eme-node.com`,
        //url: `https://bsc-dataseed2.defibit.io/`,
      },
      live: true,
      saveDeployments: false,
      tags: ['local'],
      timeout: 2000000,
    },
    Map: {
      url: `https://rpc.maplabs.io/`,
      chainId : 22776,
      accounts: accounts
    },
    Makalu: {
      url: `https://testnet-rpc.maplabs.io/`,
      chainId : 212,
      accounts: accounts
    },
    Matic: {
      url: `https://rpc-mainnet.maticvigil.com`,
      chainId : 137,
      accounts: accounts
    },
    MaticTest: {
      url: `https://rpc-mumbai.maticvigil.com/`,
      chainId : 80001,
      accounts: accounts
    },
    Bsc: {
      url: `https://bsc-dataseed1.binance.org/`,
      chainId : 56,
      accounts: accounts
    },
    BscTest: {
      url: `https://data-seed-prebsc-2-s1.binance.org:8545/`,
      chainId : 97,
      accounts: accounts,
      gasPrice: 11 * 1000000000
    },
    Klay: {
      url: `https://public-en-cypress.klaytn.net`,
      chainId : 8217,
      accounts: accounts
    },
    KlayTest: {
      url: `https://public-en-baobab.klaytn.net`,
      chainId : 1001,
      accounts: accounts
    },
    Eth: {
      url: `https://mainnet.infura.io/v3/` + INFURA_KEY,
      chainId : 1,
      accounts: accounts
    },
    Goerli: {
      url: `https://goerli.infura.io/v3/` + INFURA_KEY,
      chainId : 5,
      accounts: accounts
    },
    Arbitrum: {
      url: `https://1rpc.io/arb`,
      chainId : 42161,
      accounts: accounts
    },
    Op: {
      url: `https://1rpc.io/op`,
      chainId : 10,
      accounts: accounts
    },
    Avax: {
      url: `https://rpc.ankr.com/avalanche`,
      chainId : 43114,
      accounts: accounts
    },
    Fantom: {
      url: `https://1rpc.io/ftm`,
      chainId : 250,
      accounts: accounts
    },
    Gnosis: {
      url: `https://rpc.ankr.com/gnosis`,
      chainId : 100,
      accounts: accounts
    },
    Aurora: {
      url: `https://mainnet.aurora.dev`,
      chainId : 1313161554,
      accounts: accounts
    },

    Celo: {
      url: `https://rpc.ankr.com/celo`,
      chainId : 42220,
      accounts: accounts
    },
    Harmony: {
      url: `https://api.harmony.one`,
      chainId : 1666600000,
      accounts: accounts
    },
    zkSync: {
      url: `https://mainnet.era.zksync.io`,
      chainId : 324,
      accounts: accounts
    },
    zkEvm: {
      url: `https://zkevm-rpc.com`,
      chainId : 1101,
      accounts: accounts
    },
    Boba: {
      url: `https://mainnet.boba.network`,
      chainId : 288,
      accounts: accounts
    },
    Metis: {
      url: `https://andromeda.metis.io/?owner=1088`,
      chainId : 1088,
      accounts: accounts
    },

    Cronos: {
      url: `https://cronos-evm.publicnode.com`,
      chainId : 25,
      accounts: accounts
    },
    Kava: {
      url: `https://evm.kava.io`,
      chainId : 2222,
      accounts: accounts
    },
    Evmos: {
      url: `https://evmos-evm.publicnode.com`,
      chainId : 9001,
      accounts: accounts
    },

    Moonbeam: {
      url: `https://rpc.api.moonbeam.network`,
      chainId : 1284,
      accounts: accounts
    },
    Moonriver: {
      url: `https://rpc.api.moonriver.moonbeam.network`,
      chainId : 1285,
      accounts: accounts
    },
    Astar: {
      url: `https://evm.astar.network`,
      chainId : 592,
      accounts: accounts
    },
    Conflux: {
      url: `https://evm.confluxrpc.com`,
      chainId : 1030,
      accounts: accounts
    },
    Oasis: {
      url: `https://emerald.oasis.dev`,
      chainId : 42262,
      accounts: accounts
    },
    Velas: {
      url: `https://explorer.velas.com/rpc`,
      chainId : 106,
      accounts: accounts
    },
    Telos: {
      url: `https://rpc1.eu.telos.net/evm`,
      chainId : 40,
      accounts: accounts
    },
    Syscoin: {
      url: `https://rpc.syscoin.org`,
      chainId : 57,
      accounts: accounts
    },
    Ethw: {
      url: `https://mainnet.ethereumpow.org`,
      chainId : 10001,
      accounts: accounts
    },
  },
  solidity: {
    compilers: [
      {
        version: '0.8.7',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: '0.4.22',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  spdxLicenseIdentifier: {
    overwrite: true,
    runOnCompile: true,
  },
  mocha: {
    timeout: 2000000,
  },
  etherscan: {
    apiKey: process.env.BSC_SCAN_KEY,
  },
}
