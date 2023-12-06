forge b --skip test script --build-info

forge script scripts/v2/local/update/upgrade.s.sol:Upgrade \
    --rpc-url http://127.0.0.1:8545 \
    --broadcast \
    --verbosity

# python deploy.py
python3 deploy.py
