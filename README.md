# Shared Fund

Create or join a crypto investment portfolio with constant proportions that is balancing when the market moves.

Your share in a Portfolio is represented as a NFT that can be transfer. You can claim your share back at any moment.

The Portfolio is rebalanced using Chainlink to determine the moment and Uniswap to execute the swap.

## Specification

```mermaid
sequenceDiagram
    actor Owner
    participant Contract
    Note over Owner : Initialize Portfolio
    Owner ->> Contract : deploy()
    Note over Owner : Auto invite to the Portfolio  
    Owner ->> Contract : invite()
    Note over Owner : Add ETH to the Portfolio
    Owner ->> Contract : deposit()
    Note over Owner : Add WBTC to the Portfolio
    Owner ->> Contract : add_asset(token_address, proportion)
    Note over Owner : Change assets proportions
    Owner ->> Contract : change_proportions(token_address, proportion)
    Note over Owner : Rebalance to the Portfolio
    Owner ->> Contract : rebalance()
    loop Rebalance each token
        Contract ->> Chainlink : get_token_price()
        Chainlink ->> Contract : token_price
        Contract ->> Uniswap : swap_token()
    end
    Note over Owner : Invite new Owner to the Portfolio
    Owner ->> Contract : invite()
    Note over Owner : Withdraw from the Portfolio
    Owner ->> Contract : withdraw()
```

## Design

### Smart Contrcat

![graph](resources/graph.png)

## Stack

- Foundry / Anvil
- WAGMI (React)
- Chainlink
- Uniswap
- OpenZeppelin
- Solidity

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
cd app && yarn && yarn dev # start the app
# import the private key from anvil to your wallet
# open the app in http://localhost:3000
# connect your wallet and start using the app
# change the network of your wallet to localhost:8545
# change the chainId of the localnet on metamask to 1
# copy your public address and invite yourself
# using the "Invite New Owner" button in "/fund" 
```
