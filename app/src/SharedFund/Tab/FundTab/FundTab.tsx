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
import CoinChooser from "./CoinChooser/CoinChooser";
import ConfirmModal from "../../ConfirmModal/ConfirmModal";

function FundTab(props){

    const [modalPercentage, setModalPercentage] = React.useState(false);
    const [modalCoin, setModalCoin] = React.useState(false);
    const [fundBalance, setFundBalance] = React.useState(0);
    const [pieData, setPieData] = React.useState([]);
    const [rebalanceModal, setRebalanceModal] = React.useState(false);
    const [modalOwner, setModalOwner] = React.useState(false);

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
        <div style={{paddingBottom:15}} className="fund-tab">
            <div className={"fund-tab__info"}>
                <div className="fund-tab__info__chart">
                    <button className="fund-tab__info__chart-update"><img onClick={() => setModalPercentage(true)} src={pen}/></button>
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
                    <button onClick={() => setModalOwner(true)}> Invite a new owner</button>
                </div>
            </div>

            <hr/>

            <div className="your-currencies">
                <h2> Your Currencies </h2>
                <button className="your-currencies__update"><img onClick={() => setModalCoin(true)} src={pen}/></button>
            </div>
            <SymbolSumUp assets={props.fund.assets} balance={fundBalance}/>
            <div onClick={() => setRebalanceModal(true)} className="rebalance">
                <img src={updateIcon}/>
                <label> Rebalance </label>
            </div>

            <Modal title={"Update percentages"} isOpen={modalPercentage} onClose={() => setModalPercentage(false)}>
                <AssetSliders assets={props.fund.assets}/>
            </Modal>

            <Modal title={"Update Portfolio coin"} isOpen={modalCoin} onClose={() => setModalCoin(false)}>
                <CoinChooser assets={props.fund.assets}/>
            </Modal>

            <Modal title={"Invite a new member"} isOpen={modalOwner} onClose={() => setModalOwner(false)}>
                <div className="modal-with-input">
                    <div className="modal-with-input__input">
                        <label> Address of the member : </label>
                        <input type="text"/>
                    </div>
                    <button> Confirmer </button>
                </div>
            </Modal>

            <ConfirmModal modalOpen={rebalanceModal} setOpen={setRebalanceModal}></ConfirmModal>
        </div>
    )
}

export default FundTab;