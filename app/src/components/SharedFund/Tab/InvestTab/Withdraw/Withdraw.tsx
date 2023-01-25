import { useState } from "react";
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
  const [nftId, setNftId] = useState(0);
  const [amount, setAmount] = useState(0);
  const {
    config,
    error: prepareError,
    isError: isPrepareError,
  } = usePrepareContractWrite({
    address,
    abi,
    functionName: "withdraw",
    args: [amount],
  });
  const { data, error, isError, write } = useContractWrite(config);

  const { isLoading, isSuccess } = useWaitForTransaction({
    hash: data?.hash,
  });

  return (
    <div>
      <input value={amount}></input>
      <button disabled={!write || isLoading} onClick={() => write()}>
        {isLoading ? "Deposit..." : "Deposit"}
      </button>
      {isSuccess && (
        <div>
          Successfully deposited
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
