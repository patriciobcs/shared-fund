function deploy {
  forge script script/priceFeedsScript.s.sol:ChainlinkScript --rpc-url $GOERLI_RPC_URL  --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_KEY -vvvv
}