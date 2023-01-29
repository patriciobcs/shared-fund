import { writeContract } from "@wagmi/core";
import React, { useEffect } from "react";
import RangeSlider from "react-range-slider-input";
import "react-range-slider-input/dist/style.css";
import "./AssetSliders.scss";
import { sharedFundContract } from "../../../../../App";
import { Asset } from "../../../../../hooks/useAssets";

async function changeAssets(currentAssets, newAssets, onClose) {
    console.log(currentAssets, newAssets);
    const transactionsHashes = [];
    // get elements that are in currentAssets but not in newAssets
    const toRemove = currentAssets.filter((asset) => {
        return newAssets.every((a) => a.coin.symbol !== asset.coin.symbol || a.proportion === 0);
    });
    // get elements that are in newAssets but not in currentAssets
    const toAdd = newAssets.filter((asset) => {
        return currentAssets.every((a) => a.coin.symbol !== asset.coin.symbol);
    });
    // get elements that are in both but have different proportions
    const toChange = currentAssets.filter((asset) => {
        if (asset.coin.symbol === "WETH") return false;
        const possibleAsset = newAssets.filter((a) => a.coin.symbol === asset.coin.symbol);
        return possibleAsset.length === 1 && possibleAsset[0].proportion !== asset.proportion;
    });
    console.log(toRemove, toAdd, toChange);
    // remove elements
    await toRemove.map(async (asset) => {
        // remove asset from the fund
        // not implemented in smart contract yet
        // const { hash } = await writeContract({
        //     ...sharedFundContract,
        //     mode: 'recklesslyUnprepared',
        //     functionName: 'removeAsset',
        //     args: [asset.coin.address],
        // });
        // transactionsHashes.push(hash);
    });
    // add elements
    await toAdd.map(async (asset) => {
        // add asset to the fund
        console.log("adding asset", asset);
        const { hash } = await writeContract({
            ...sharedFundContract,
            mode: 'recklesslyUnprepared',
            functionName: 'addAsset',
            args: [asset.coin.address, asset.proportion * 100, asset.coin.feed],
        });
        console.log("hash", hash);
        transactionsHashes.push(hash);
    });
    // change elements
    await toChange.map(async (asset) => {
        // change asset in the fund
        const { hash } = await writeContract({
            ...sharedFundContract,
            mode: 'recklesslyUnprepared',
            functionName: 'changeAssetProportion',
            args: [asset.coin.address, asset.proportion * 100],
        });
        transactionsHashes.push(hash);
    });
    onClose();
}

function AssetSliders({ currentAssets, newAssets, onClose}: { currentAssets: Asset[], newAssets?: Asset[], onClose: any }) {
  const [proportions, setProportions] = React.useState([]);
  const [disabled, setDisabled] = React.useState(false);

  useEffect(() => {
    const assets = newAssets ?? currentAssets;
    const _proportions = Object.values(assets).map((asset) => { return Object.assign({}, asset); });
    
    setProportions(_proportions);
    checkTotal(_proportions);
  }, []);

  const checkTotal = (assets) => {
    let total = 0;
    assets.map((asset) => (total += asset.proportion));
    setDisabled(total !== 100);
    return total;
  };

  const changeValue = (symbol, value) => {
    const _proportions = proportions.slice(0);
    const asset =_proportions.filter((asset) => asset.coin.symbol === symbol)[0];
    asset.proportion = value[1];
    checkTotal(_proportions);

    setProportions(_proportions);
  };

  return (
    <div className="assets-sliders">
      {proportions.map((asset) => {
        return (
          <div className="asset-slider" key={asset.coin.symbol}>
            <label> {asset.coin.label}</label>
            <div className="slider-and-proportion">
              <RangeSlider
                onInput={(value) => changeValue(asset.coin.symbol, value)}
                className="single-thumb slider"
                defaultValue={[0, asset.proportion]}
                thumbsDisabled={[true, false]}
                rangeSlideDisabled={true}
                min={0}
                max={100}
                step={1}
              />
              <label> {asset.proportion}% </label>
            </div>
          </div>
        );
      })}
      <button
        className="main-button"
        onClick={async () => await changeAssets(currentAssets, proportions, onClose)}
        disabled={disabled}
      >
        Change Proportions
      </button>

      {disabled ? (
        <label className="warning"> The total should be 100% </label>
      ) : null}
    </div>
  );
}

export default AssetSliders;
