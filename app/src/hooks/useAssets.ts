import { sharedFundContract } from "../App";

import { useState } from "react";
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
  USDC: {
    symbol: "USDC",
    address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
    feed: "0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6",
    label: "USDC",
  },
};

export function useAssets(): Asset[] {
  const [assets, setAssets] = useState<Asset[]>([]);

  useContractRead({
    ...sharedFundContract,
    functionName: "getAssets",
    watch: true,
    onSuccess(rawAssets: any) {
      console.log("rawAssets", rawAssets);
      let newAssets = [];
      let allCoins = Object.values(coins);
      for (let i = 0; i < rawAssets.length; i++) {
        // TODO: This is a hack to get the price to display correctly. Need to figure out why the price is off by 10^10
        console.log("decimals", rawAssets[i].decimals.toNumber());
        const decimals = rawAssets[i].decimals.toNumber();
        const extraDecimals = decimals > 10 ? decimals - 10 : decimals;
        const proportionDenominator = 10 ** 2;
        const coin = allCoins.filter((token) => {
          return (token.address === rawAssets[i].token);
        })[0];
        newAssets.push({
          coin,
          amount: (decimals > 10 ? rawAssets[i].amount.div(10 ** 10) : rawAssets[i].amount.toNumber()) / 10 ** extraDecimals,
          price:
            rawAssets[i].price.toNumber() / 10 ** 8,
          proportion: rawAssets[i].proportion.toNumber() / proportionDenominator,
          balance: (decimals > 10 ? rawAssets[i].balance.div(10 ** 10).div(10 ** 8).toNumber() : rawAssets[i].balance.div(10 ** 8).toNumber()) / 10 ** extraDecimals,
        });
        console.log("newAssets", newAssets);
      }
      setAssets(newAssets); 
    },
  });

  return assets;
}
