import { sharedFundContract } from "../App"

import { useState, useEffect } from "react";
import { Asset, useAssets } from "./useAssets";
import { useContractRead } from "wagmi";

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

  useContractRead({
    ...sharedFundContract,
    functionName: 'getOwners',
    watch: true,
    onSuccess(rawOwners: any) {
      let newOwners = [];
      for (let newOwner of rawOwners) {
        newOwners.push({
          name: newOwner.owner.toString(),
          address: newOwner.owner.toString(),
          tokenId: newOwner.tokenId.toString(),
          share: newOwner.share.div(10 ** 2).toNumber(),
        });
      }
      setOwners(newOwners);
    }
  });

  useEffect(() => {
    let newTotalInvestment = assets.reduce((total, asset) => {
      return total + asset.balance;
    }, 0);
    setTotalInvestment(newTotalInvestment);
  }, [assets]);

  return {
    totalInvestment,
    owners,
    assets,
  };
}