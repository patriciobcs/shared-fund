export const owners: Owner[] = [
    {
        name: "Louis Tricot",
        investment: 5000,
        address:"address1"
    },
    {
        name: "Mathieu Saugier",
        investment: 3000,
        address:"address2"
    },
    {
        name: "Patricio Calderon",
        investment: 2000,
        address:"address3"
    }
]

export const coins: {[key: string]: Coin} = {
    "WETH": { symbol: "WETH", address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", feed: "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419", label: 'Ethereum' },
    "WBTC": { symbol: "WBTC", address: "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599", feed: "0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c", label: 'Bitcoin' },
    "LINK": { symbol: "LINK", address: "0x514910771AF9Ca656af840dff83E8264EcF986CA", feed: "0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c", label: 'ChainLink' },
    "AAVE": { symbol: "AAVE", address: "0x6Df09E975c830ECae5bd4eD9d90f3A95a4f88012", feed: "0x6Df09E975c830ECae5bd4eD9d90f3A95a4f88012", label: 'Aave' },
    "USDC": { symbol: "USDC", address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", feed: "0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6", label: 'USDC' },
};

export let assets: Asset[] = [
    {
        coin: coins["WETH"],
        proportion: 50,
        amount:3,
        price: 1807,
        balance: 5422
    },
    {
        coin: coins["WBTC"],
        proportion: 40,
        amount:0.1790,
        price: 19487,
        balance: 3489
    },
    {
        coin: coins["LINK"],
        proportion: 10,
        amount:548,
        price: 2.6496,
        balance:1452
    }
]
const fund: Fund = {
    initialInvestment:10000,
    assets,
    owners
};

export interface Asset {
    coin: Coin;
    amount: number;
    price: number;
    proportion: number;
    balance: number;
}

export interface Coin {
    symbol: string;
    label: string;
    address: string;
    feed: string;
}

export const emptyAsset = {   
    coin: { symbol: "", label: "", address: "", feed: "" },
    amount: 0,
    price: 0,
    proportion: 0,
    balance: 0,
}

export interface Fund{
    assets: Asset[];
    owners: Owner[];
    initialInvestment: number;
}

export interface Owner {
    name: string;
    investment: number;
    address: string;
}

export function getOwners(){
    return owners;
}

export function getFund(){
    return fund;
}

export function getAssets(){
    return assets;
}