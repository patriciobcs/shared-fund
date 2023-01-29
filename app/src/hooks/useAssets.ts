import { readContract, watchReadContract } from "@wagmi/core";
import { sharedFundContract } from "../App";

import { useState, useEffect } from "react";
import { useContractRead } from "wagmi";

export interface Asset {
  coin: Coin;
  amount: number;
  price: number;
  proportion: number;
  balance: number;
}

export interface Coin {
  symbol: string;
  label: string;
  address: string;
  feed: string;
}

export const emptyAsset = {
  coin: { symbol: "", label: "", address: "", feed: "" },
  amount: 0,
  price: 0,
  proportion: 0,
  balance: 0,
};

export const coins: { [key: string]: Coin } = {
  WETH: {
    symbol: "WETH",
    address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
    feed: "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419",
    label: "Ethereum",
  },
  WBTC: {
    symbol: "WBTC",
    address: "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599",
    feed: "0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c",
    label: "Bitcoin",
  },
  LINK: {
    symbol: "LINK",
    address: "0x514910771AF9Ca656af840dff83E8264EcF986CA",
    feed: "0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c",
    label: "ChainLink",
  },
  AAVE: {
    symbol: "AAVE",
    address: "0x6Df09E975c830ECae5bd4eD9d90f3A95a4f88012",
    feed: "0x6Df09E975c830ECae5bd4eD9d90f3A95a4f88012",
    label: "Aave",
  },
  USDC: {
    symbol: "USDC",
    address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
    feed: "0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6",
    label: "USDC",
  },
};

export function useAssets(): Asset[] {
  const [assets, setAssets] = useState<Asset[]>([]);
  const [disposables, setDisposables] = useState([]);

  let getAssetsConfig = {
    ...sharedFundContract,
    functionName: "getAssets",
  };

  const { data: rawAssets }: any = useContractRead(getAssetsConfig);

  useEffect(() => {
    if (rawAssets === undefined) { return; }
    let newAssets = [];
    for (let i = 0; i < rawAssets.length; i++) {
      // TODO: This is a hack to get the price to display correctly. Need to figure out why the price is off by 10^10
      const priceDenominator = 10 ** (rawAssets[i].decimals.toNumber() - 10);
      const proportionDenominator = 10 ** 2;
      newAssets.push({
        coin: Object.values(coins).filter((token) => {
          return (token.address = rawAssets[i].token);
        })[0],
        amount: rawAssets[i].amount.div(10 ** 15).div(10 ** 3).toNumber(),
        price:
          rawAssets[i].price.div(priceDenominator).toNumber(),
        proportion: rawAssets[i].proportion.toNumber() / proportionDenominator,
        balance: rawAssets[i].balance.div(10 ** 15).div(10 ** 11).toNumber(),
      });
    }
    console.log("newAssets", newAssets);
    setAssets(newAssets);
  }, [rawAssets]);
    
  return assets;
}
