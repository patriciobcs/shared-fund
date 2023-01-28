import React from "react";
import Home from "./components/Home/Home";
import SharedFund from "./components/SharedFund/SharedFund";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { WagmiConfig, createClient, Address, mainnet, Chain } from "wagmi";
import { localhost } from "wagmi/chains";
import { ConnectKitProvider, getDefaultClient } from "connectkit";
import contract from "./assets/contracts/Portfolio.json";
import deployment from "./assets/contracts/run-latest.json";

export const sharedFundContract = {
  abi: contract.abi,
  address: deployment.transactions[0].contractAddress as Address,
};

export const forkMainnet: Chain = {
  ...mainnet,
  rpcUrls: {
    default: { http: ['http://localhost:8545'] },
    public: { http: ['http://localhost:8545'] },
  }
}

const client = createClient(
  getDefaultClient({
    appName: "Shared Fund",
    chains: [forkMainnet],
  })
);

function App() {
  return (
    <WagmiConfig client={client}>
      <ConnectKitProvider theme="auto">
        <BrowserRouter>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/fund" element={<SharedFund />} />
          </Routes>
        </BrowserRouter>
      </ConnectKitProvider>
    </WagmiConfig>
  );
}

export default App;
