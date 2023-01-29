import { readContract, watchReadContract } from "@wagmi/core"
import { sharedFundContract } from "../App"

import { useState, useEffect } from "react";
import { Asset, useAssets } from "./useAssets";

export interface Owner {
  name: string;
  address: string;
  tokenId: number;
  share: number;
}

export interface Fund {
  assets: Asset[];
  owners: Owner[];
  totalInvestment: number;
}

export function useFund(): Fund {
  const [totalInvestment, setTotalInvestment] = useState(0);
  const [owners, setOwners] = useState<Owner[]>([]);
  const assets = useAssets();
  const [disposables, setDisposables] = useState([]);

  function dispose(replaceDisposables) {
    disposables.forEach((unwatch) => unwatch());
    setDisposables(replaceDisposables);
  }

  useEffect(() => {
    let newTotalInvestment = assets.reduce((total, asset) => {
      return total + asset.balance;
    }, 0);
    setTotalInvestment(newTotalInvestment);
  }, [assets]);

  const loadOwners = async (rawOwners?: any) => {
    if (rawOwners === undefined) {
      let getOwnersConfig = {
        ...sharedFundContract,
        functionName: 'getOwners',
      };
      rawOwners = await readContract(getOwnersConfig)
      const unwatch = watchReadContract(getOwnersConfig, loadOwners);
      dispose([unwatch]);
    }
    console.log("rawOwners", rawOwners);
    let newOwners = [];
    for (let newOwner of rawOwners) {
      newOwners.push({
        name: newOwner.owner.toString(),
        address: newOwner.owner.toString(),
        tokenId: newOwner.tokenId.toString(),
        share: newOwner.share.div(10 ** 2).toNumber(),
      });
    }
    console.log("newOwners", newOwners);
    setOwners(newOwners);
  }

  useEffect(() => {
    loadOwners();
  }, []);

  return {
    totalInvestment,
    owners,
    assets,
  };
}
