import "./SharedFund.scss";
import "../Home/Home.scss";
import Header from "../Header/Header";
import { useState } from "react";
import FundTab from "./Tab/FundTab/FundTab";
import InvestTab from "./Tab/InvestTab/InvestTab";
import { useFund } from "../../hooks/useFund";

function SharedFund() {
  const [tab, setTab] = useState("fund");
  const fund = useFund();

  return (
    <div>
      <Header />
      <div className="fund-titles">
        <h1
          onClick={() => setTab("fund")}
          className={tab === "fund" ? "active" : null}
        >
          The Fund
        </h1>
        <h1
          onClick={() => setTab("invest")}
          className={tab === "invest" ? "active" : null}
        >
          Your Investment
        </h1>
      </div>
      {tab === "fund" ? <FundTab fund={fund} /> : <InvestTab fund={fund} />}
    </div>
  );
}

export default SharedFund;
