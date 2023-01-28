import {
  usePrepareContractWrite,
  useContractWrite,
  useWaitForTransaction,
} from "wagmi";
import { useDebounce } from "use-debounce";
import { sharedFundContract } from "../../../App";
import { ethers } from "ethers";

export function Transaction({ functionName }) {
  const [nftId, ] = useDebounce('1', 500);
  const [amount, setAmount] = useDebounce('1', 500);
  let args = [];

  switch (functionName) {
    case "deposit":
      args = [parseInt(amount)];
      break;
    case "withdraw":
      args = [parseInt(nftId), parseInt(amount)];
      break;
    default:
      break;
  }

  const {
    config,
    error: prepareError,
    isError: isPrepareError,
  } = usePrepareContractWrite({
    ...sharedFundContract,
    functionName,
    args,
    enabled: Boolean(amount),
    overrides: {
      value: ethers.utils.parseEther('1'),
    },
  });
  const { data, error, isError, write } = useContractWrite(config);
  const { isLoading, isSuccess } = useWaitForTransaction({ hash: data?.hash });

  return (
    <div className="vertical-list">
      <label>Amount</label>
      <input
        disabled={!write || isLoading}
        type="text"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
      />
      <button
        disabled={!write || isLoading}
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
