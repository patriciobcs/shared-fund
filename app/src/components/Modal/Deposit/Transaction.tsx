import {
  usePrepareContractWrite,
  useContractWrite,
  useWaitForTransaction,
} from "wagmi";
import { sharedFundContract } from "../../../App";
import { useState } from "react";

export function Transaction(nftId) {
  const [amount, setAmount] = useState(1);

  const isEnabled = amount > 0 && Boolean(nftId);

  const {
    config,
    error: prepareError,
    isError: isPrepareError,
  } = usePrepareContractWrite({
    ...sharedFundContract,
    functionName: "deposit",
    args: [nftId],
    enabled: isEnabled,
    overrides: {
      value: amount,
    },
  });
  const { data, error, isError, write } = useContractWrite(config);
  const { isLoading, isSuccess } = useWaitForTransaction({ hash: data?.hash });

  return (
    <div className="vertical-list">
      <label>Amount</label>
      <input
        disabled={!write || isLoading}
        type="number"
        value={amount}
        onChange={(e) => setAmount(parseInt(e.target.value))}
      />
      <button
        disabled={!isEnabled || !write || isLoading}
        className="main-button"
        type="submit"
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
            Error: {(prepareError || error)?.message.split(";")[0]}
          </label>
        )}
      </div>
    </div>
  );
}
