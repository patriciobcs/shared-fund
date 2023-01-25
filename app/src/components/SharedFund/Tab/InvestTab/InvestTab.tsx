import { PieChart } from "react-minimal-pie-chart";
import { useEffect, useState } from "react";
import randomColor from "randomcolor";
import "../Tab.scss";
import "./InvestTab.scss";
import { Owner } from "../../../../Simulation";
import Modal from "../../../Modal/Modal";
import { Deposit } from "./Deposit/Deposit";

function InvestTab(props) {
  const [fundBalance, setFundBalance] = useState(0);
  const [pieData, setPieData] = useState([]);
  const [owner] = useState<Owner>(props.fund.owners[0]);
  const [roi, setRoi] = useState(0);
  const [percentage, setPercentage] = useState(0);
  const [modalDeposit, setModalDeposit] = useState(false);

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
          <h2> Your balance : {fundBalance * percentage} $ </h2>
        </div>

        <div className="fund-tab__side-tab">
          <h2> Statistics </h2>
          <ul>
            <li>
              {" "}
              Percentage of the fund : {(percentage * 100).toFixed(2)} %{" "}
            </li>
            <li> Your Investment : {owner.investment} $ </li>
            <li> ROI : {(roi * 100).toFixed(2)} % </li>
          </ul>
          <button
            style={{width: "100%"}}
            onClick={() => {
              setModalDeposit(true);
            }}
          >
            Deposit
          </button>
          <button style={{width: "100%"}}>Withdraw</button>
          <button style={{width: "100%"}}>Sell Shares</button>
        </div>

        <Modal
          title={"Amount"}
          isOpen={modalDeposit}
          onClose={() => setModalDeposit(false)}
        >
          <Deposit />
        </Modal>
      </div>
    </div>
  );
}

export default InvestTab;
