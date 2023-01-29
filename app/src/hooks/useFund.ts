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

  let getOwnersConfig = {
    ...sharedFundContract,
    functionName: 'getOwners',
  };
  const { data: rawOwners }: any = useContractRead(getOwnersConfig);

  useEffect(() => {
    let newTotalInvestment = assets.reduce((total, asset) => {
      return total + asset.balance;
    }, 0);
    setTotalInvestment(newTotalInvestment);
  }, [assets]);

  useEffect(() => {
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
  }, [rawOwners]);

  return {
    totalInvestment,
    owners,
    assets,
  };
}
