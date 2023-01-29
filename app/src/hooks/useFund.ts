import { readContract, watchReadContract } from "@wagmi/core"
import { sharedFundContract } from "../App"

import { useState, useEffect } from "react";
import { Asset, useAssets } from "./useAssets";

export interface Owner {
  name: string;
  address: string;
  tokenId: number;
  investment: number;
}

export interface Fund {
  assets: Asset[];
  owners: Owner[];
  initialInvestment: number;
}

export function useFund(): Fund {
  const [initialInvestment, setInitialInvestment] = useState(0);
  const [owners, setOwners] = useState<Owner[]>([]);
  const assets = useAssets();
  const [disposables, setDisposables] = useState([]);

  function dispose(replaceDisposables) {
    disposables.forEach((unwatch) => unwatch());
    setDisposables(replaceDisposables);
  }

  async function loadOwners(rawOwners?: any) {
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
        investment: newOwner.investment.toNumber(),
      });
    }
    console.log("newOwners", newOwners);
    setOwners(newOwners);
  }

  useEffect(() => {
    loadOwners();
  }, []);

  return {
    initialInvestment,
    owners,
    assets,
  };
}
