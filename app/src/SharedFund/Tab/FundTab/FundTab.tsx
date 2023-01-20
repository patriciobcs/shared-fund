import {PieChart} from "react-minimal-pie-chart";
import Owner from "./Owner/Owner";
import SymbolSumUp from "./SymbolSumUp/SymbolSumUp";
import updateIcon from "../../../assets/update.png";
import React, {useEffect} from "react";
import pen from "../../../assets/pen.png";
import Modal from "../../../Modal/Modal";
import AssetSliders from "./AssetSliders/AssetSliders";
import randomColor from "randomcolor";
import "../Tab.scss";
import "./FundTab.scss";

function FundTab(props){

    const [modalOpen, setOpen] = React.useState(false);
    const [fundBalance, setFundBalance] = React.useState(0);
    const [pieData, setPieData] = React.useState([]);

    useEffect(() => {
        const data = [];
        let balance = 0;
        props.fund.assets.map(a => {
            balance+= a.balance
            data.push({
                title: a.name,
                value: a.proportion,
                color: randomColor(),
            });
        });
        setPieData(data);
        setFundBalance(balance)
    },[props.fund])
    return (
        <div style={{ height: 1500}} className="fund-tab">
            <div className={"fund-tab__info"}>
                <div className="fund-tab__info__chart">
                    <button className="fund-tab__info__chart-update"><img onClick={() => setOpen(true)} src={pen}/></button>
                    <PieChart
                        data={pieData}
                        label={({ dataEntry }) => dataEntry.title +" : " + dataEntry.value + "%" }
                        labelStyle={(index) => ({
                            fontSize:'0.20rem',
                            fill:"white",
                        })}
                        paddingAngle={18}
                        rounded
                        labelPosition={60}
                        lineWidth={20}
                    />
                    <h2> Fund Balance : {fundBalance} $ </h2>
                </div>

                <div className = "fund-tab__side-tab">
                    <h2> Owners </h2>
                    <ul>
                        {
                            props.fund.owners.map((owner) => {
                                return <li><Owner key={owner.name} name={owner.name} percentage={(owner.investment/props.fund.initialInvestment)*100}/></li>
                            })
                        }
                    </ul>
                    <button> Invite a new owner</button>
                </div>
            </div>

            <hr/>

            <h2 className="your-currencies"> Your Currencies </h2>
            <SymbolSumUp assets={props.fund.assets} balance={fundBalance}/>
            <div className="rebalance">
                <img src={updateIcon}/>
                <label> Rebalance </label>
            </div>

            <Modal title={"Update percentages"} isOpen={modalOpen} onClose={() => setOpen(false)}>
                <AssetSliders assets={props.fund.assets}/>
            </Modal>
        </div>
    )
}

export default FundTab;