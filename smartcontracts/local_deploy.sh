forge b --skip test script --build-info

forge script scripts/v2/local/deploy.s.sol:Local \
    --rpc-url http://127.0.0.1:8545 \
    --broadcast \
    --verbosity

python deploy.py

forge script scripts/v2/local/validation/buy.s.sol:Buy \
    --rpc-url http://127.0.0.1:8545 \
    --broadcast \
    --verbosity

forge script scripts/v2/local/validation/dex.s.sol:OrderBook \
    --rpc-url http://127.0.0.1:8545 \
    --broadcast \
    --verbosity
