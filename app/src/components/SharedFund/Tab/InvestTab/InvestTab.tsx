import { PieChart } from "react-minimal-pie-chart";
import { useEffect, useState } from "react";
import randomColor from "randomcolor";
import "../Tab.scss";
import "./InvestTab.scss";
import { Owner } from "../../../../Simulation";
import Modal from "../../../Modal/Modal";
import { Transaction } from "../../../Modal/Transaction/Transaction";

function InvestTab(props) {
  const [fundBalance, setFundBalance] = useState(0);
  const [pieData, setPieData] = useState([]);
  const [owner] = useState<Owner>(props.fund.owners[0]);
  const [roi, setRoi] = useState(0);
  const [percentage, setPercentage] = useState(0);
  const [modalDeposit, setModalDeposit] = useState(false);
  const [modalWithdraw, setModalWithdraw] = useState(false);

  useEffect(() => {
    const data = [];
    let balance = 0;
    props.fund.assets.map((a) => {
      balance += a.balance;
    });
    let percentage = owner.investment / props.fund.initialInvestment;
    setPercentage(percentage);

    props.fund.assets.map((a) => {
      data.push({
        title: a.name,
        value: a.balance * percentage,
        color: randomColor(),
      });
    });

    setPieData(data);
    setRoi((balance * percentage) / owner.investment);
    setFundBalance(balance);
  }, [props.fund]);

  return (
    <div style={{ height: 750 }} className="fund-tab">
      <div className="fund-tab__info">
        <div className="fund-tab__info__chart">
          <PieChart
            data={pieData}
            label={({ dataEntry }) =>
              dataEntry.title + " : " + dataEntry.value + "$"
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
          <h2> Your Balance: {fundBalance * percentage} USD </h2>
        </div>

        <div className="fund-tab__side-tab">
          <h1> Statistics </h1>
          <div className="vertical-list">
            <label>Fund Percentage: {(percentage * 100).toFixed(0)}%</label>
            <label>Your Investment: ${owner.investment}</label>
            <label>ROI: {(roi * 100).toFixed(2)}% </label>
          </div>
          <div className="vertical-list" style={{ paddingTop: "3rem" }}>
            <button
              className="main-button"
              onClick={() => {
                setModalDeposit(true);
              }}
            >
              Deposit
            </button>
            <button
              className="main-button"
              onClick={() => {
                setModalWithdraw(true);
              }}
            >
              Withdraw
            </button>
            <button className="main-button">Sell Shares</button>
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
