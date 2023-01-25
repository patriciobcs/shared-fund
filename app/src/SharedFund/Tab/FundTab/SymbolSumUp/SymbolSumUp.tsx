import "./SymbolSumUp.scss"
import React, {useEffect} from "react";



function SymbolSumUp(props){
    return (
        <table className="sumup">
            <thead>
                <tr className="sumup__tr">
                    <th>#</th>
                    <th>Name </th>
                    <th>Price</th>
                    <th>Amount</th>
                    <th>Total</th>
                    <th>Real Percentage</th>
                    <th>Goal Percentage</th>
                </tr>
            </thead>
            <tbody>
            {props.assets.map((asset, index) => {
                return (
                    <tr key={index}>
                        <td>{index+1}</td>
                        <td>{asset.name} <label className="sumup__symbol">{asset.symbol}</label></td>
                        <td>{asset.price} $</td>
                        <td>{asset.amount}</td>
                        <td>{asset.balance} $</td>
                        <td>{(100*asset.balance/props.balance).toFixed(2)} %</td>
                        <td>{asset.proportion} %</td>
                    </tr>
                );
            })}
            </tbody>
        </table>
    );
}

export default SymbolSumUp;