import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();


type HttpNetworkAccountsUserConfig = any;
const config: HardhatUserConfig = {

  defaultNetwork: "theta_privatenet",
  networks: {
    theta_privatenet: {
      url: "http://localhost:18888/rpc",
      accounts: [process.env.PRIVATE_KEY] as HttpNetworkAccountsUserConfig | undefined,
      chainId: 366,
      gasPrice: 4000000000000
    },
    theta_testnet: {
      url: `https://eth-rpc-api-testnet.thetatoken.org/rpc`,
      accounts: [process.env.PRIVATE_KEY] as HttpNetworkAccountsUserConfig | undefined,
      chainId: 365,
      gasPrice: 4000000000000
    }

  },
  solidity: {
    version: '0.8.9',
    settings: {
      optimizer: {
        enabled: true,
        runs: 800,
      },
      metadata: {
        // do not include the metadata hash, since this is machine dependent
        // and we want all generated code to be deterministic
        // https://docs.soliditylang.org/en/v0.7.6/metadata.html
        bytecodeHash: 'none',
      },
    },
  },
};



export default config;
