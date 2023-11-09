source .env
forge b --skip test script --build-info

forge script scripts/v2/testnet/deploy.s.sol:Testnet \
    --private-key $MUMBAI_PRIVATE_KEY \
    --rpc-url $MUMBAI_RPC_URL \
    --broadcast \
    --verbosity

python3 deploy.py
# forge script scripts/v2/local/deploy.s.sol:Local \
#     --rpc-url http://127.0.0.1:8545 \
#     --broadcast \
#     --verbosity
