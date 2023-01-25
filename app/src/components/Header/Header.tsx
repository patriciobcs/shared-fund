import React from 'react';
import './Header.scss';
import whiteLogo from "../../assets/logo-white.png";
import {Link} from "react-router-dom";
import Profile from '../Profile/Profile';
import { WagmiConfig, createClient, configureChains, mainnet } from 'wagmi'
import { alchemyProvider } from 'wagmi/providers/alchemy'
import { publicProvider } from 'wagmi/providers/public'
import { InjectedConnector } from 'wagmi/connectors/injected'
import { MetaMaskConnector } from 'wagmi/connectors/metaMask'
import { WalletConnectConnector } from 'wagmi/connectors/walletConnect'
 
// import abi from "../../../out/Portfolio.sol/Portfolio.json";

// console.log(abi);
// Configure chains & providers with the Alchemy provider.
// Two popular providers are Alchemy (alchemy.com) and Infura (infura.io)
const { chains, provider, webSocketProvider } = configureChains(
  [mainnet],
  [alchemyProvider({ apiKey: process.env.REACT_APP_GOERLI_API_KEY }), publicProvider()],
)

const client = createClient({
  autoConnect: true,
  connectors: [
    new MetaMaskConnector({ chains }),
    new WalletConnectConnector({
      chains,
      options: {
        qrcode: true,
      },
    }),
    new InjectedConnector({
      chains,
      options: {
        name: 'Injected',
        shimDisconnect: true,
      },
    }),
  ],
  provider,
  webSocketProvider,
})

function Header() {
    return (
        <header className="header">
            <Link to="/">
                <img className="header__logo" src={whiteLogo}></img>
            </Link>
            <nav className="header__nav">
                <a href="#">About Us</a>
                <a href="#">Documentation</a>
                <button className="header__create-fund-button"><Link to="/fund">Your fund</Link> </button>
                <WagmiConfig client={client}>
                    <Profile />
                </WagmiConfig>
            </nav>
        </header>
    );
}

export default Header;
