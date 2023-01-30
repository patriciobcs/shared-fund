import {
  usePrepareContractWrite,
  useContractWrite,
  useWaitForTransaction,
} from "wagmi";
import { sharedFundContract } from "../../../App";
import {useEffect, useState} from "react";
import { ethers } from "ethers";

export function Withdraw({ tokenId }) {
  const [amount, setAmount] = useState('1');

  const isEnabled = amount.length > 0 && parseInt(amount) > 0 && Boolean(tokenId);

  const {
    config,
    error: prepareError,
    isError: isPrepareError,
  } = usePrepareContractWrite({
    ...sharedFundContract,
    functionName: "withdraw",
    args: [tokenId, isEnabled ? parseInt(amount)*100 : 1],
    enabled: isEnabled
  });
  const { data, error, isError, write } = useContractWrite(config);
  const { isLoading, isSuccess } = useWaitForTransaction({ hash: data?.hash });

  console.log(tokenId, amount);

  return (
    <div className="vertical-list">
      <label>Percentage</label>
      <input
        disabled={isLoading}
        type="number"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
      />
      <button
        disabled={!isEnabled || !write || isLoading}
        className="main-button"
        type="submit"
        onClick={() => write()}
      >
        Send
      </button>
      <div className="info">
        {isSuccess && (
          <div>
            Success (
            <a href={`https://etherscan.io/tx/${data?.hash}`}>Etherscan</a>)
          </div>
        )}
        {(isPrepareError || isError) && (
          <label className="warning">
            {" "}
            Error: {(prepareError || error)?.message?.split(";")[0]}
          </label>
        )}
      </div>
    </div>
  );
}
