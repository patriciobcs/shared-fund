import { PieChart } from "react-minimal-pie-chart";
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
import { Address } from "../../../Modal/Address/Address";

function FundTab({ fund }) {
  const [modalPercentage, setModalPercentage] = useState(false);
  const [modalCoin, setModalCoin] = useState(false);
  const [fundBalance, setFundBalance] = useState(0);
  const [pieData, setPieData] = useState([]);
  const [rebalanceModal, setRebalanceModal] = useState(false);
  const [modalOwner, setModalOwner] = useState(false);

  useEffect(() => {
    const data = [];
    let balance = 0;
    fund.assets.forEach((a) => {
      balance += a.balance;
      data.push({
        title: a.coin.symbol,
        value: a.proportion,
        color: randomColor(),
      });
    });
    setPieData(data);
    setFundBalance(balance);
  }, [fund.assets]);

  return (
    <div style={{ paddingBottom: 15 }} className="fund-tab">
      <div className={"fund-tab__info"}>
        <div className="fund-tab__info__chart">
          <button className="fund-tab__info__chart-update">
            <img
              onClick={() => setModalPercentage(true)}
              src={pen}
              alt="update"
            />
          </button>
          <PieChart
            data={pieData}
            label={({ dataEntry }) =>
              dataEntry.title + " " + dataEntry.value + "%"
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
          <h2> Fund Balance: ${fundBalance} USD </h2>
        </div>

        <div className="fund-tab__side-tab vertical-list">
          <h1>Owners</h1>
          {fund.owners.map((owner) => {
            return (
              <Owner
                key={owner.address}
                name={owner.name}
                share={owner.share}
              />
            );
          })}
          <div className="vertical-list" style={{ paddingTop: "3rem" }}>
            <button className="main-button" onClick={() => setModalOwner(true)}>
              Invite New Owner
            </button>
            <button
              className="main-button"
              onClick={() => setRebalanceModal(true)}
            >
              Rebalance
            </button>
          </div>
        </div>
      </div>

      <div className="your-currencies">
        <h1>Your Currencies</h1>
        <button className="your-currencies__update">
          <img onClick={() => setModalCoin(true)} src={pen} alt="update" />
        </button>
      </div>
      <SymbolSumUp assets={fund.assets} balance={fundBalance} />

      <Modal
        title={"Update percentages"}
        isOpen={modalPercentage}
        onClose={() => setModalPercentage(false)}
      >
        <AssetSliders
          currentAssets={fund.assets}
          onClose={() => setModalPercentage(false)}
        />
      </Modal>

      <Modal
        title={"Update Portfolio coin"}
        isOpen={modalCoin}
        onClose={() => setModalCoin(false)}
      >
        <CoinChooser
          assets={fund.assets}
          onClose={() => setModalCoin(false)}
        />
      </Modal>

      <Modal
        title={"Invite New Owner"}
        isOpen={modalOwner}
        onClose={() => setModalOwner(false)}
      >
        <Address functionName={"invite"} />
      </Modal>

      <ConfirmModal
        modalOpen={rebalanceModal}
        setOpen={setRebalanceModal}
      ></ConfirmModal>
    </div>
  );
}

export default FundTab;
