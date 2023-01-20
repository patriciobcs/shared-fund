import {PieChart} from "react-minimal-pie-chart";
import React, {useEffect} from "react";
import randomColor from "randomcolor";
import "../Tab.scss";
import "./InvestTab.scss";
import { Owner } from "../../../Simulation";

function InvestTab(props){

    const [fundBalance, setFundBalance] = React.useState(0);
    const [pieData, setPieData] = React.useState([]);
    const [owner, setOwner] = React.useState<Owner>(props.fund.owners[0]);
    const [roi, setRoi] = React.useState(0);
    const [percentage, setPercentage] = React.useState(0);

    useEffect(() => {

        const data = [];
        let balance = 0;
        props.fund.assets.map(a => {
            balance+= a.balance;
        });
        let percentage = owner.investment/props.fund.initialInvestment;
        setPercentage(percentage);


        props.fund.assets.map(a => {
            data.push({
                title: a.name,
                value: a.balance*percentage,
                color: randomColor()
            })
        })

        setPieData(data);
        setRoi(balance*percentage/owner.investment);
        setFundBalance(balance)

    },[props.fund]);

    return (
        <div style={{ height: 750}} className="fund-tab">
            <div className="fund-tab__info">
                <div className="fund-tab__info__chart">
                    <PieChart
                        data={pieData}
                        label={({ dataEntry }) => dataEntry.title +" : " + dataEntry.value + "$" }
                        labelStyle={(index) => ({
                            fontSize:'0.20rem',
                            fill:"white",
                        })}
                        paddingAngle={18}
                        rounded
                        labelPosition={60}
                        lineWidth={20}
                    />
                    <h2> Your balance : {fundBalance*percentage} $ </h2>
                </div>

                <div className = "fund-tab__side-tab">
                    <h2> Statistics </h2>
                    <ul>
                        <li> Percentage of the fund : {(percentage*100).toFixed(2)} %  </li>
                        <li> Your Investment : {owner.investment} $ </li>
                        <li> ROI : {(roi*100).toFixed(2)} % </li>
                    </ul>
                    <button> Invest </button>
                    <button> Withdraw </button>
                    <button> Sell Shares </button>
                </div>
            </div>
        </div>
    )
}

export default InvestTab;