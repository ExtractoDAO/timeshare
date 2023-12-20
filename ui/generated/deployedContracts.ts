const deployedContracts = {
  "31337": [
    {
      name: "localhost",
      chainId: "31337",
      contracts: {
        NewContract: {
          address: "0x0B306BF915C4d645ff596e518fAf3F9669b97016",
          abi: [
            { inputs: [], stateMutability: "nonpayable", type: "constructor" },
            {
              inputs: [],
              name: "getYieldFarming",
              outputs: [{ internalType: "uint256", name: "yieldFarming", type: "uint256" }],
              stateMutability: "view",
              type: "function",
            },
            {
              inputs: [
                { internalType: "address", name: "owner", type: "address" },
                { internalType: "uint256", name: "x", type: "uint256" },
              ],
              name: "init",
              outputs: [],
              stateMutability: "nonpayable",
              type: "function",
            },
          ],
        },
      },
    },
  ],
} as const;

export default deployedContracts;
