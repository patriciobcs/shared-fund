import "./CoinChooser.scss"
import React, {useEffect} from "react";
import Select from "react-select";
import {Asset, emptyAsset} from "../../../../Simulation";
import AssetSliders from "../AssetSliders/AssetSliders";
import Modal from "../../../../Modal/Modal";

export const allCoins = [
    { value: 'eth', label: 'Ethereum', address:"test" },
    { value: 'btc', label: 'Bitcoin' , address:"test2"},
    { value: 'uni', label: 'Uniswap', address: "test3" },
    { value: 'link', label: 'ChainLink', address: "test4" },
    { value: 'dot', label: 'Polkadot', address: "test5" },
    { value: 'avax', label: 'Avax', address: "test6" },
];


function CoinChooser(props){

    const [fundCoins, setFundCoins] = React.useState<Asset[]>([emptyAsset]);
    const [fundCoinNames, setNames] = React.useState([]);
    const [filteredCoinList, setFiltered] = React.useState(allCoins);
    const [modalPercentage, setModalPercentage] = React.useState(false);

    const selectChange = (event, index) => {
        const _coins = fundCoins;
        const _names = fundCoinNames;

        _names[index] = event.label;
        _coins[index].symbol = event.value;
        _coins[index].name = event.label;


        setNames([..._names]);
        setFundCoins([..._coins]);
    }

    const addCoin = () => {
        const _coins = fundCoins;
        const _names = fundCoinNames;

        _names.push("");
        _coins.push(emptyAsset);
        setNames([..._names]);
        setFundCoins([..._coins]);
    }

    useEffect(() => {
        const _f = allCoins.filter((c) => {
                return !(fundCoinNames.includes(c.label));
        });
        setFiltered([..._f]);
    },[fundCoins, fundCoinNames]);

    const removeCoin = (index) => {
        let _coins = fundCoins;
        let _names = fundCoinNames;
        _names = _names.filter((e,i) => {
            return i != index;
        })
        _coins = _coins.filter((e,i) => {
            return i != index;
        })
        setFundCoins([..._coins]);
        setNames([..._names]);
    }

    useEffect(() => {
        const _coins = [];
        const _names = [];
        props.assets.map((a) => {
            _coins.push(a)
            _names.push(a.name);
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
                    {fundCoins.map((coin, index) => {
                        return (
                            <tr key={coin.symbol+index}>
                                <td>{index+1}</td>
                                <td>
                                    <Select
                                        onChange={(event) => selectChange(event,index)}
                                        value={{label:fundCoins[index].name}}
                                        {...props}
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
            <div style={{display:"flex", justifyContent:"center"}}>
                <button className="add-coin" onClick={addCoin}> Add Coin </button>
                <button className="add-coin" onClick={()=> setModalPercentage(true)}> Confirm </button>
            </div>

            <Modal title={"Update percentages"} isOpen={modalPercentage} onClose={() => setModalPercentage(false)}>
                <AssetSliders assets={fundCoins}/>
            </Modal>
        </div>
    )
}

export default CoinChooser