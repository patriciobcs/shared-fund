import * as React from "react";
import {
  usePrepareContractWrite,
  useContractWrite,
  useWaitForTransaction,
  Address,
} from "wagmi";

import contract from "../../../../../assets/contracts/Portfolio.json";
import deployment from "../../../../../assets/contracts/run-latest.json";

const abi = contract.abi;
const address = deployment.transactions[0].contractAddress as Address;
  
export function Deposit() {
  const {
    config,
    error: prepareError,
    isError: isPrepareError,
  } = usePrepareContractWrite({
    address,
    abi,
    functionName: "deposit",
    args: [1],
  });
  const { data, error, isError, write } = useContractWrite(config);

  const { isLoading, isSuccess } = useWaitForTransaction({
    hash: data?.hash,
  });

  return (
    <div>
      <button disabled={!write || isLoading} onClick={() => write()}>
        {isLoading ? "Investing..." : "Invest"}
      </button>
      {isSuccess && (
        <div>
          Successfully invest
          <div>
            <a href={`https://etherscan.io/tx/${data?.hash}`}>Etherscan</a>
          </div>
        </div>
      )}
      {(isPrepareError || isError) && (
        <div>Error: {(prepareError || error)?.message.split(";")[0]}</div>
      )}
    </div>
  );
}
