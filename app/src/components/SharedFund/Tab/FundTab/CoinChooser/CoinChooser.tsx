import "./CoinChooser.scss"
import React, {useEffect} from "react";
import Select from "react-select";
import AssetSliders from "../AssetSliders/AssetSliders";
import Modal from "../../../../Modal/Modal";
import { Asset, coins, emptyAsset } from "../../../../../hooks/useAssets";

function CoinChooser({ assets, onClose }){
    const allCoins = Object.values(coins);
    const [fundCoins, setFundCoins] = React.useState<Asset[]>([emptyAsset]);
    const [fundCoinNames, setNames] = React.useState([]);
    const [filteredCoinList, setFiltered] = React.useState(allCoins);
    const [modalPercentage, setModalPercentage] = React.useState(false);

    const selectChange = (event, index) => {
        const _coins = fundCoins;
        const _names = fundCoinNames;

        console.log(event, index);

        _names[index] = event.label;
        _coins[index].coin = event;

        setNames([..._names]);
        setFundCoins(_coins);
    }

    const addCoin = () => {
        const _coins = fundCoins;
        const _names = fundCoinNames;

        _names.push("");
        _coins.push(emptyAsset);
        setNames([..._names]);
        setFundCoins(_coins);
    }

    useEffect(() => {
        const _f = allCoins.filter((c) => {
                return !(fundCoinNames.includes(c.label));
        });
        setFiltered([..._f]);
    }, [fundCoins, fundCoinNames]);

    const removeCoin = (index) => {
        let _coins = fundCoins;
        let _names = fundCoinNames;
        _names = _names.filter((e,i) => {
            return i !== index;
        })
        _coins = _coins.filter((e,i) => {
            return i !== index;
        })
        setFundCoins([..._coins]);
        setNames([..._names]);
    }

    useEffect(() => {
        const _coins = [];
        const _names = [];
        assets.map((asset) => {
            _coins.push(Object.assign({}, asset));
            _names.push(asset.coin.label);
        });
        setNames(_names);
        setFundCoins(_coins);
    },[])

    return (
        <div>
            <div className="coin-choose">
                <table className="coin-choose__table">
                    <thead>
                    <tr>
                        <th>#</th>
                        <th>Name </th>
                        <th></th>
                    </tr>
                    </thead>
                    <tbody>
                    {fundCoins.map((asset, index) => {
                        return (
                            <tr key={asset.coin.symbol+index}>
                                <td>{index+1}</td>
                                <td>
                                    <Select
                                        onChange={(event) => selectChange(event,index)}
                                        value={{label: fundCoins[index].coin.label}}
                                        {...{ allCoins }}
                                        maxMenuHeight={100}
                                        className="react-select-container"
                                        classNamePrefix="react-select"
                                        options={filteredCoinList}/>
                                </td>
                                <td> <button className="remove" onClick={() => removeCoin(index)}> - </button> </td>
                            </tr>
                        );
                    })}
                    </tbody>
                </table>
            </div>
            <div className="horizontal-list">
                <button className="main-button" onClick={addCoin}> Add Coin </button>
                <button className="main-button" onClick={()=> setModalPercentage(true)}> Confirm </button>
            </div>

            <Modal title={"Update percentages"} isOpen={modalPercentage} onClose={() => setModalPercentage(false)}>
                <AssetSliders currentAssets={assets} newAssets={fundCoins} onClose={() => { setModalPercentage(false); onClose();}}/>
            </Modal>
        </div>
    )
}

export default CoinChooser