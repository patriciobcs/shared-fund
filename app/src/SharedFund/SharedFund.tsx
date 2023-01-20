import "./SharedFund.scss"
import "../Home/Home.scss"
import Header from "../Header/Header";
import React, {useEffect} from "react";
import {Fund, getFund} from "../Simulation";
import FundTab from "./Tab/FundTab/FundTab";
import InvestTab from "./Tab/InvestTab/InvestTab";


function SharedFund(props){
    const [tab, setTab] = React.useState("fund");
    const [fund, setFund] = React.useState<Fund>({owners:[], assets:[],initialInvestment:0});

    useEffect(() => {
        const _fund = getFund();
        setFund(_fund);
    },[]);

    return(
        <div style={{backgroundColor:"#1c1c1c"}}>
            <Header/>
            <div className="fund-titles">
                <h1 onClick={() => setTab("fund")} className={tab == "fund" ? "active" : null}> The Fund </h1>
                <h1 onClick={() => setTab("invest")} className={tab == "invest" ? "active" : null} > Your Investment </h1>
            </div>
            { tab == "fund" ?
                <FundTab fund={fund}/>
                :
                <InvestTab fund={fund}/>
            }
        </div>
    )
}

export default SharedFund;