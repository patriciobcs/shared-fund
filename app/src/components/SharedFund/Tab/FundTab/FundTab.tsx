import {PieChart} from "react-minimal-pie-chart";
import Owner from "./Owner/Owner";
import SymbolSumUp from "./SymbolSumUp/SymbolSumUp";
import { useEffect, useState } from "react";
import pen from "../../../../assets/pen.png";
import Modal from "../../../Modal/Modal";
import AssetSliders from "./AssetSliders/AssetSliders";
import randomColor from "randomcolor";
import "../Tab.scss";
import "./FundTab.scss";
import CoinChooser from "./CoinChooser/CoinChooser";
import ConfirmModal from "../../../Modal/ConfirmModal/ConfirmModal";

function FundTab(props){

    const [modalPercentage, setModalPercentage] = useState(false);
    const [modalCoin, setModalCoin] = useState(false);
    const [fundBalance, setFundBalance] = useState(0);
    const [pieData, setPieData] = useState([]);
    const [rebalanceModal, setRebalanceModal] = useState(false);
    const [modalOwner, setModalOwner] = useState(false);

    useEffect(() => {
        const data = [];
        let balance = 0;
        props.fund.assets.map(a => {
            balance+= a.balance
            data.push({
                title: a.coin.symbol,
                value: a.proportion,
                color: randomColor(),
            });
        });
        setPieData(data);
        setFundBalance(balance)
    },[props.fund])
    return (
        <div style={{paddingBottom:15}} className="fund-tab">
            <div className={"fund-tab__info"}>
                <div className="fund-tab__info__chart">
                    <button className="fund-tab__info__chart-update"><img onClick={() => setModalPercentage(true)} src={pen} alt="update"/></button>
                    <PieChart
                        data={pieData}
                        label={({ dataEntry }) => dataEntry.title +" " + dataEntry.value + "%" }
                        labelStyle={(index) => ({
                            fontSize:'0.20rem',
                            fill:"white",
                        })}
                        paddingAngle={18}
                        rounded
                        labelPosition={60}
                        lineWidth={20}
                    />
                    <h2> Fund Balance: {fundBalance} USD </h2>
                </div>

                <div className = "fund-tab__side-tab vertical-list">
                    <h1>Members</h1>
                    {
                        props.fund.owners.map((owner) => {
                            return <Owner name={owner.name} percentage={(owner.investment/props.fund.initialInvestment)*100}/>
                        })
                    }
                    <div className="vertical-list" style={{paddingTop: "3rem"}}>
                        <button className="main-button" onClick={() => setModalOwner(true)}>Invite New Member</button>
                        <button className="main-button" onClick={() => setRebalanceModal(true)}>Rebalance</button>
                    </div>
                </div>
            </div>

            <div className="your-currencies">
                <h1>Your Currencies</h1>
                <button className="your-currencies__update"><img onClick={() => setModalCoin(true)} src={pen} alt="update"/></button>
            </div>
            <SymbolSumUp assets={props.fund.assets} balance={fundBalance}/>

            <Modal title={"Update percentages"} isOpen={modalPercentage} onClose={() => setModalPercentage(false)}>
                <AssetSliders assets={props.fund.assets}/>
            </Modal>

            <Modal title={"Update Portfolio coin"} isOpen={modalCoin} onClose={() => setModalCoin(false)}>
                <CoinChooser assets={props.fund.assets}/>
            </Modal>

            <Modal title={"Invite New Member"} isOpen={modalOwner} onClose={() => setModalOwner(false)}>
                <div className="modal-with-input">
                    <div className="vertical-list">
                        <label>Member Address</label>
                        <input type="text"/>
                    </div>
                    <button className="main-button"> Confirm </button>
                </div>
            </Modal>

            <ConfirmModal modalOpen={rebalanceModal} setOpen={setRebalanceModal}></ConfirmModal>
        </div>
    )
}

export default FundTab;