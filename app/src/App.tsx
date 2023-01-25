import React from 'react';
import Home from "./components/Home/Home";
import SharedFund from "./components/SharedFund/SharedFund";
import {BrowserRouter, Routes, Route} from "react-router-dom";
import { WagmiConfig, createClient } from 'wagmi';
import { localhost } from 'wagmi/chains';
import { ConnectKitProvider, getDefaultClient } from 'connectkit';

const client = createClient(
  getDefaultClient({
    appName: 'My App Name',
    //infuraId: process.env.REACT_APP_INFURA_ID,
    //alchemyId:  process.env.REACT_APP_ALCHEMY_ID,
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
