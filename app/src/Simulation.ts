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

export let assets: Asset[] = [
    {
        symbol: "ETH",
        name: "Ethereum",
        proportion: 50,
        amount:3,
        price: 1807,
        balance: 5422
    },
    {
        symbol: "BTC",
        name: "Bitcoin",
        proportion: 40,
        amount:0.1790,
        price: 19487,
        balance: 3489
    },
    {
        symbol: "LINK",
        name: "ChainLink",
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

export interface Asset{
    symbol: string;
    name: string;
    amount: number;
    price: number;
    proportion: number;
    balance: number;
}

export const emptyAsset = {   symbol: "",
    name: "",
    amount: 0,
    price: 0,
    proportion: 0,
    balance: 0
};

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