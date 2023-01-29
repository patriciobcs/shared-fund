import { PieChart } from "react-minimal-pie-chart";
import { useEffect, useState } from "react";
import randomColor from "randomcolor";
import "../Tab.scss";
import "./InvestTab.scss";
import Modal from "../../../Modal/Modal";
import { Transaction } from "../../../Modal/Transaction/Transaction";
import { getAccount } from "@wagmi/core";

function InvestTab({ fund }) {
  const [fundBalance, setFundBalance] = useState(0);
  const [pieData, setPieData] = useState([]);
  const [investment, setInvestment] = useState(0);
  const [roi, setRoi] = useState(0);
  const [percentage, setPercentage] = useState(0);
  const [modalDeposit, setModalDeposit] = useState(false);
  const [modalWithdraw, setModalWithdraw] = useState(false);
  const [nftId, setNftId] = useState(null);

  useEffect(() => {
    const data = [];
    const account = getAccount();
    const possibleOwners = fund.owners.filter(
      (o) => o.address === account.address
    );
    if (possibleOwners.length === 1) {
      const currentOwner = possibleOwners[0];
      setNftId(currentOwner.nftId);
      setPercentage(currentOwner.share);
      setFundBalance(fund.totalInvestment);

      if (currentOwner.share > 0) {
        fund.assets.forEach((a) => {
          data.push({
            title: a.coin.symbol,
            value: a.balance * currentOwner.share,
            color: randomColor(),
          });
        });

        setPieData(data);
        setInvestment(currentOwner.share * fund.totalInvestment);
      }
    } else {
      setPieData([]);
      setFundBalance(0);
      setInvestment(0);
      setNftId(null);
    }
  }, [fund.owners, fund.assets, fund.totalInvestment]);

  return (
    <div style={{ height: 750 }} className="fund-tab">
      <div className="fund-tab__info">
        <div className="fund-tab__info__chart">
          <PieChart
            data={pieData}
            label={({ dataEntry }) =>
              dataEntry.title + " $" + dataEntry.value + ""
            }
            labelStyle={(index) => ({
              fontSize: "0.20rem",
              fill: "white",
            })}
            paddingAngle={18}
            rounded
            labelPosition={60}
            lineWidth={20}
          />
          <h2> Your Balance: ${fundBalance * percentage} USD </h2>
        </div>

        <div className="fund-tab__side-tab">
          <h1> {nftId !== null ? "Statistics" : "Only Invited"}</h1>
          {nftId !== null ? (
            <div className="vertical-list">
              <label>Fund Percentage: {(percentage * 100).toFixed(0)}%</label>
              <label>Your Investment: ${investment}</label>
              {/* <label>ROI: {(roi * 100).toFixed(2)}% </label> */}
            </div>
          ) : (
            <label>
              You need an invitation to being able to invest in this fund.
            </label>
          )}
          <div className="vertical-list" style={{ paddingTop: "3rem" }}>
            <button
              disabled={nftId === null}
              className="main-button"
              onClick={() => {
                setModalDeposit(true);
              }}
            >
              Deposit
            </button>
            <button
              disabled={nftId === null}
              className="main-button"
              onClick={() => {
                setModalWithdraw(true);
              }}
            >
              Withdraw
            </button>
            <button disabled={nftId === null} className="main-button">
              Sell Shares
            </button>
          </div>
        </div>

        <Modal
          title={"Deposit"}
          isOpen={modalDeposit}
          onClose={() => setModalDeposit(false)}
        >
          <Transaction functionName={"deposit"} />
        </Modal>

        <Modal
          title={"Withdraw"}
          isOpen={modalWithdraw}
          onClose={() => setModalWithdraw(false)}
        >
          <Transaction functionName={"withdraw"} />
        </Modal>
      </div>
    </div>
  );
}

export default InvestTab;
