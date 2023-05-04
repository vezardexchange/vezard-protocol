import "@matterlabs/hardhat-zksync-deploy";
import "@matterlabs/hardhat-zksync-solc";
import "@matterlabs/hardhat-zksync-verify";
import dotenv from "dotenv";

dotenv.config();

const ETHER_SCAN_APIKEY = process.env.ETHER_SCAN_APIKEY;

module.exports = {
  zksolc: {
    version: "1.3.8",
    compilerSource: "binary",
    settings: {},
  },
  defaultNetwork: "zkSyncTestnet",

  networks: {
    zkSyncTestnet: {
      url: "https://testnet.era.zksync.dev",
      ethNetwork: "https://goerli.infura.io/v3/f7a811d6cb97446e8efed8db535f0ed8", // RPC URL of the network (e.g. `https://goerli.infura.io/v3/<API_KEY>`)
      zksync: true,
      verifyURL: 'https://zksync2-testnet-explorer.zksync.dev/contract_verification'
    },
    zkSync: {
      url: "https://zksync2-mainnet.zksync.io",
      ethNetwork: "mainnet", // RPC URL of the network (e.g. `https://goerli.infura.io/v3/<API_KEY>`)
      zksync: true,
      verifyURL: 'https://zksync2-mainnet-explorer.zksync.io/contract_verification'
    },
  },
  etherscan: {
    apiKey: ETHER_SCAN_APIKEY,
  },
  solidity: {
    version: "0.8.13",
  },
};
