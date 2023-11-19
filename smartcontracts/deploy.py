"""
Automation for update debug section in front-end
"""
from dataclasses import dataclass, field
from json import dumps, load
from typing import List

@dataclass
class Contract:
    """
        # Contract must have:
        - contractAddress: str
        - contractName: str
        - abi: list
    """
    name: str
    address: str
    abi: list = field(default_factory=list)


CHAIN_ID = 80001
CONTRACT_SCRIPT_NAME = "deploy.s.sol"
TRANSACTIONS_PATH = f"broadcast/{CONTRACT_SCRIPT_NAME}/{CHAIN_ID}/run-latest.json"
TARGET_DIR = "../../frontend/v2/src/generated/deployedContracts.ts"

TOKENS = ["USDT", "USDC"]
DIAMOND_ADDRESS = ""

def abi_path(name) -> str:
    if(name == "MockToken"):
        return f"artifacts/{name}.t.sol/{name}.json"
    else:
        return f"artifacts/{name}.sol/{name}.json"

with open(TRANSACTIONS_PATH) as deployed_contracts:
    json_file = load(deployed_contracts)
    transactions = json_file["transactions"]
    transactions.append({
        "transactionType":"CREATE",
        "contractName": "Future",
        "contractAddress": "0x61c36a8d610163660E21a8b7359e1Cac0C9133e1"
    })
    contracts: List[Contract] = []

    for contract in transactions:
        if contract["transactionType"] == "CREATE":
            name, address = contract["contractName"], contract["contractAddress"]
            if name == "Diamond":
                DIAMOND_ADDRESS = address
            with open(abi_path(name)) as full_abi_json:
                abi = load(full_abi_json)["abi"]

                if name == "MockToken":
                    name = TOKENS[0]
                    TOKENS.remove(TOKENS[0])

                contracts.append(Contract(name, address, abi))

    for contract in contracts:
        if contract.name in ["Commodity", "Dex"]:
            contract.address = DIAMOND_ADDRESS




json_config = {
    CHAIN_ID: [
        {
            "name": "mumbai",
            "chainId": str(CHAIN_ID),
            "contracts": {}
        }
    ]
}


for contract in contracts:
    json_config[CHAIN_ID][0]["contracts"][contract.name] = {
        "address": contract.address,
        "abi": contract.abi
    }


typescript_content = f"const deployedContracts = {dumps(json_config)} as const; \n\n export default deployedContracts"


with open(TARGET_DIR, "w") as ts_file:
    ts_file.write(typescript_content)