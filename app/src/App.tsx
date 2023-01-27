import React from 'react';
import Home from "./components/Home/Home";
import SharedFund from "./components/SharedFund/SharedFund";
import {BrowserRouter, Routes, Route} from "react-router-dom";
import { WagmiConfig, createClient, Address } from 'wagmi';
import { localhost } from 'wagmi/chains';
import { ConnectKitProvider, getDefaultClient } from 'connectkit';
import contract from "./assets/contracts/Portfolio.json";
import deployment from "./assets/contracts/run-latest.json";
export const abi = contract.abi;
export const address = deployment.transactions[0].contractAddress as Address;

const client = createClient(
  getDefaultClient({
    appName: 'Shared Fund',
    chains: [localhost],
  })
);

function App() {
  return (
    <WagmiConfig client={client}>
      <ConnectKitProvider theme="auto">
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Home/>}/>
          <Route path="/fund" element={<SharedFund/>}/>
        </Routes>
      </BrowserRouter>
      </ConnectKitProvider>
      </WagmiConfig>
  );
}

export default App;
