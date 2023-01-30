import { PieChart } from "react-minimal-pie-chart";
import { useEffect, useState } from "react";
import randomColor from "randomcolor";
import "../Tab.scss";
import "./InvestTab.scss";
import Modal from "../../../Modal/Modal";
import { Deposit } from "../../../Modal/Deposit/Deposit";
import { getAccount } from "@wagmi/core";
import { Withdraw } from "../../../Modal/Withdraw/Withdraw";
import {Address} from "../../../Modal/Address/Address";

function InvestTab({ fund }) {
  const [fundBalance, setFundBalance] = useState(0);
  const [pieData, setPieData] = useState([]);
  const [investment, setInvestment] = useState(0);
  // const [roi, setRoi] = useState(0);
  const [percentage, setPercentage] = useState(0);
  const [modalDeposit, setModalDeposit] = useState(false);
  const [modalWithdraw, setModalWithdraw] = useState(false);
  const [modalShares, setModalShares] = useState(false);
  const [tokenId, setTokenId] = useState(null);

  const isMember = tokenId !== null;

  useEffect(() => {
    const data = [];
    const account = getAccount();
    const possibleOwners = fund.owners.filter(
      (o) => o.address === account.address
    );
    if (possibleOwners.length === 1) {
      const currentOwner = possibleOwners[0];
      setTokenId(currentOwner.tokenId);
      setPercentage(currentOwner.share);
      setFundBalance(fund.totalInvestment);

      if (currentOwner.share > 0) {
        fund.assets.forEach((a) => {
          if (a.balance === 0) return;
          data.push({
            title: a.coin.symbol,
            value: a.balance * currentOwner.share / 100,
            color: randomColor(),
          });
        });

        setPieData(data);
        setInvestment(currentOwner.share * fund.totalInvestment / 100);
      }
    } else {
      setPieData([]);
      setFundBalance(0);
      setInvestment(0);
      setTokenId(null);
    }
  }, [fund.owners, fund.assets, fund.totalInvestment]);

  return (
    <div style={{ height: 750 }} className="fund-tab">
      <div className="fund-tab__info">
        <div className="fund-tab__info__chart">
          <PieChart
            data={pieData}
            label={({ dataEntry }) =>
              dataEntry.title + " $" + dataEntry.value.toFixed(0) + ""
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
          <h2> Your Balance: ${(fundBalance * percentage / 10 ** 2).toFixed(0)} USD </h2>
        </div>

        <div className="fund-tab__side-tab">
          <h1> {isMember ? "Statistics" : "Only Invited"}</h1>
          {isMember ? (
            <div className="vertical-list">
              <label>Fund Percentage: {percentage}%</label>
              <label>Your Investment: ${investment.toFixed(0)} USD</label>
              {/* <label>ROI: {(roi * 100).toFixed(2)}% </label> */}
            </div>
          ) : (
            <label>
              You need an invitation to being able to invest in this fund.
            </label>
          )}
          <div className="vertical-list" style={{ paddingTop: "3rem" }}>
            <button
              disabled={!isMember}
              className="main-button"
              onClick={() => {
                setModalDeposit(true);
              }}
            >
              Deposit
            </button>
            <button
              disabled={!isMember}
              className="main-button"
              onClick={() => {
                setModalWithdraw(true);
              }}
            >
              Withdraw
            </button>
            <button
                disabled={!isMember}
                onClick={() => {
                  setModalShares(true)
                }}
                className="main-button">
              Sell Shares
            </button>
          </div>
        </div>

        <Modal
          title={"Deposit"}
          isOpen={modalDeposit}
          onClose={() => setModalDeposit(false)}
        >
          <Deposit tokenId={tokenId} />
        </Modal>

        <Modal
          title={"Withdraw"}
          isOpen={modalWithdraw}
          onClose={() => setModalWithdraw(false)}
        >
          <Withdraw tokenId={tokenId} />
        </Modal>

        <Modal
            title={"Sell your shares to someone"}
            isOpen={modalShares}
            onClose={() => setModalShares(false)}
        >
          <Address functionName={"transferShares"} />
        </Modal>
      </div>
    </div>
  );
}

export default InvestTab;
