import {
  usePrepareContractWrite,
  useContractWrite,
  useWaitForTransaction,
} from "wagmi";
import { sharedFundContract } from "../../../App";
import { useState } from "react";

export function Address(props) {
  const [address, setAddress] = useState("0x");
  const isAddress = address.length === 42;

  const {
    config,
    error: prepareError,
    isError: isPrepareError,
  } = usePrepareContractWrite({
    ...sharedFundContract,
    functionName: props.functionName,
    args: [address],
    enabled: isAddress,
  });
  const { data, error, isError, write } = useContractWrite(config);
  const { isLoading, isSuccess } = useWaitForTransaction({ hash: data?.hash });

  console.log(error, prepareError);
  return (
    <div className="vertical-list">
      <div className="modal-with-input">
        <div className="vertical-list">
          <label>Address</label>
          <input
            disabled={isLoading}
            type="text"
            placeholder="0x..."
            value={address}
            onChange={(e) => setAddress(e.target.value)}
          />
        </div>
        <button disabled={!isAddress || !write || isLoading} className="main-button" onClick={write}>
          Confirm
        </button>
      </div>
      <div className="info">
        {isSuccess && (
          <div>
            Success (
            <a href={`https://etherscan.io/tx/${data?.hash}`}>Etherscan</a>)
          </div>
        )}
        {isAddress && (isPrepareError || isError) && (
          <label className="warning">
            {" "}
            Error: {(prepareError || error)?.message?.split(";")[0]}
          </label>
        )}
      </div>
    </div>
  );
}
