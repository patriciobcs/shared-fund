import React, {useEffect} from "react";
import RangeSlider from 'react-range-slider-input';
import 'react-range-slider-input/dist/style.css';
import "./AssetSliders.scss"
import Modal from "../../../../Modal/Modal";
import ConfirmModal from "../../../ConfirmModal/ConfirmModal";

function AssetSliders(props){

    const [proportions, setProportions] = React.useState({});
    const [disabled, setDisabled] = React.useState(false);
    const [modalOpen, setOpen] = React.useState(false);


    useEffect(() => {
        const _proportions = {};
        props.assets.map((a) => _proportions[a.symbol] = a.proportion)
        setProportions(_proportions);

        checkTotal(_proportions);
    },[props.assets])

    const checkTotal = (prop) => {
        let total = 0;
        Object.keys(prop).map(a => total += prop[a]);
        setDisabled(total != 100);
    };

    const changeValue = (symbol,value) => {
        const _proportions = proportions;
        _proportions[symbol] = value[1];
        setProportions({..._proportions});

        checkTotal(_proportions);
    }

    return (
        <div className="assets-sliders">
            {
                props.assets.map(a => {
                    return <div className="asset-slider" key={a.symbol}>
                                <label> {a.name} : </label>
                                <div className="slider-and-proportion">
                                    <RangeSlider
                                        onInput={(value) => changeValue(a.symbol,value)}
                                        className="single-thumb slider"
                                        defaultValue={[0, a.proportion]}
                                        thumbsDisabled={[true, false]}
                                        rangeSlideDisabled={true}
                                        step={1}
                                    />
                                    <label> {proportions[a.symbol]} % </label>
                                </div>
                        </div>
                })
            }
            <button className="change" onClick={() => setOpen(true)} disabled={disabled}> Change Proportions </button>
            { disabled ?
                <label className="warning"> The total should be 100% </label>
                :
                null
            }

            <ConfirmModal modalOpen={modalOpen} setOpen={setOpen}></ConfirmModal>
        </div>
    )
}

export default AssetSliders;