-include .env

.PHONY: all install slither format lint anvil deploy deploy-goerli deploy-anvil

all: install

install :; forge install 

slither :; slither ./src 

format :; forge fmt

lint :; solhint src/**/*.sol && solhint src/*.sol

anvil :; anvil -m 'test test test test test test test test test test test junk'

anvil-fork-mainnet :; anvil --fork-url ${MAINNET_RPC_URL} -b 3

# use the "@" to hide the command from your shell 
deploy-goerli :; @forge script script/${contract}.s.sol:Deploy${contract} --rpc-url ${GOERLI_RPC_URL}  --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY}  -vvvv

# This is the private key of account from the mnemonic from the "make anvil" command
deploy-anvil :; @forge script script/${contract}.s.sol:Deploy${contract} --rpc-url http://localhost:8545  --broadcast

deploy :; make deploy-${network} contract=PriceFeedConsumer