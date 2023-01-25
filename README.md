# Shared Fund

Create or join a crypto investment portfolio with constant proportions that is balancing when the market moves.

Your share in a Portfolio is represented as a NFT that can be transfer. You can claim your share back at any moment.

The Portfolio is rebalanced using Chainlink to determine the moment and Uniswap to execute the swap.

```mermaid
sequenceDiagram
    actor Founder
    participant Contract
    Note over Founder : Initialize Portfolio
    Founder ->> Contract : deposit()
    Note over Founder : Add first token
    Founder ->> Contract : add_token(token_address, token_share)
    Contract ->> Chainlink : get_token_price()
    Chainlink ->> Contract : token_price
    Contract ->> Uniswap : swap_token()
```

## Stack

- Foundry
- WAGMI (React)
- Chainlink
- Uniswap
- Solidity

## APIs

The following are the methods available in the contract. All the method pointed with majority emit events.

```solidity
invite(address) //  only majority shareholders

deposit() // only shareholders

getTokenPrice() 

rebalance() // only majority shareholders

update_repartition() // only majority shareholders

add_token()

add_token_auto_rebalance()

remove_token()

remove_token_auto_rebalance()

copy()

sell_share()

withdraw()
```

## Quickstart

It is necessary to have installed [Foundry](https://book.getfoundry.sh/getting-started/installation) to be able to build, test and deploy the project. After setting up foundry, use the following commands to setup, test and deploy the project:

```sh
make # setup the project
forge test # run the tests locally
make anvil-fork-mainnet # start a mainnet fork
# modify the .env file to add:
# - the private key (found the last output of previous command)
# - the mainnet rpc url (you can get one in alchemy.com)
make deploy-anvil # deploy the contract to the mainnet fork
cd app && yarn && yarn start # start the app
# change the network of your wallet to localhost:8545
# open the app in http://localhost:3000
# connect your wallet and start using the app
```
