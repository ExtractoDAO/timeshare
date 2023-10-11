cast call \
    --private-key "6ae17d5c55325633c5aab3fdadc56d071960b3c129075c475d146002153fb458" \
    --rpc-url "https://polygon-mainnet.g.alchemy.com/v2/A2QxFNmyp__wev3DqLlMbJaqqqZdsq8j" \
    "0x9C9e5fD8bbc25984B178FdCE6117Defa39d2db39" "approve(address, uint256)(bool)" \
    "0x0246BB7FFe92aAf8203685760D02E00433E9CD91" 1000000000000000000 \
    -vvvv

cast call \
    --private-key "6ae17d5c55325633c5aab3fdadc56d071960b3c129075c475d146002153fb458" \
    --rpc-url "https://polygon-mainnet.g.alchemy.com/v2/A2QxFNmyp__wev3DqLlMbJaqqqZdsq8j" \
    "0x0246BB7FFe92aAf8203685760D02E00433E9CD91" "createFuture(address, uint256)(address, uint256)" \
    "0x9C9e5fD8bbc25984B178FdCE6117Defa39d2db39" 1000000000000000000 \
    -vvvv
