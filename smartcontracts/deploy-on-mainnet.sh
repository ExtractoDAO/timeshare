source .env

forge script scripts/deploy.dao.mainnet.sol:Polygon \
    --rpc-url $POLYGON_RPC_URL \
    --broadcast
