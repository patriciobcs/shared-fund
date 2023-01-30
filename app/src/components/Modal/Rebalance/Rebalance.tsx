import Modal from "../Modal";
import React from "react";
import "./Rebalance.scss";
import { useContractWrite, usePrepareContractWrite, useWaitForTransaction } from "wagmi";
import { sharedFundContract } from "../../../App";

function Rebalance(props) {
  const {
    config,
    error: prepareError,
    isError: isPrepareError,
  } = usePrepareContractWrite({
    ...sharedFundContract,
    functionName: "rebalance",
  });
  const { data, error, isError, write } = useContractWrite(config);
  const { isLoading, isSuccess } = useWaitForTransaction({ hash: data?.hash });
  
  return (
    <div>
      <Modal
        title={"Rebalance"}
        isOpen={props.modalOpen}
        onClose={() => props.setOpen(false)}
      >
        <div className="confirm">
          <label> { !isLoading ? "Are you sure?" : "Loading..." } </label>
          <div className="horizontal-list">
            <button 
            onClick={() => { write() }}
            disabled={isLoading || !write} className="main-button">
              Yes
            </button>
            <button
              disabled={isLoading || !write}
              className="main-button"
              onClick={() => props.setOpen(false)}
            >
              No
            </button>
          </div>
        </div>
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
            Error: {(prepareError || error)?.message}
          </label>
        )}
      </div>
      </Modal>
    </div>
  );
}

export default Rebalance;
