import React, { useState } from "react";
import { Button } from "./components/Button";
import { Input } from "./components/Input";
import { SelectToken } from "./components/SelectToken";
import { useScaffoldContractWrite } from "~~/hooks/scaffold-eth";
import { ethers } from "ethers";
import deployedContracts from "~~/generated/deployedContracts";

export const Buy = () => {
  const [amount, setAmount] = useState<number>(0);
  const [commodAmount, setCommodAmount] = useState<number>(0);
  const Price = 2;

  const handleAmountChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const value = event.target.value;
    const numericValue = parseFloat(value);
    setAmount(Number.isNaN(numericValue) ? 0 : numericValue);
    setCommodAmount(Number.isNaN(numericValue) ? 0 : numericValue * Price);
  };

  const handleCommodAmountChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const value = event.target.value;
    const numericValue = parseFloat(value);
    setCommodAmount(Number.isNaN(numericValue) ? 0 : numericValue);
    setAmount(Number.isNaN(numericValue) ? 0 : numericValue / Price);
  };

  const getDecimals = (token:string) => {
    return 18
  }

  const selectedToken = "MockToken";

  const { writeAsync: approveAsync } = useScaffoldContractWrite({
    contractName: selectedToken,
    functionName: "approve",
    args: [deployedContracts[31337][0].contracts.Commodity.address, ethers.utils.parseUnits(amount.toString(), getDecimals(selectedToken))],
    blockConfirmations: 1,
    onBlockConfirmation: txnReceipt => {
      console.log("Transaction blockHash", txnReceipt.blockHash);
    },
  });

  const handleApprove = async () => {
    
  };

  const handleConfirm = () => {
   
  };

  return (
    <div className="max-w-[640px] flex flex-col mt-6 px-7 py-8 bg-base-200 opacity-80 rounded-2xl shadow-lg border-2 border-primary">
      <SelectToken />

      <div className="m-auto w-4/5 h-[88px] bg-slate-50 border-slate-200 border-solid border-[1px] rounded-[4px]">
        <Input
          id="amount"
          inputMode="numeric"
          type="text"
          pattern="\d*"
          placeholder="Amount"
          required={true}
          value={amount.toString()}
          onChange={handleAmountChange}
        />
      </div>

      <div className="m-auto w-4/5 h-[88px] bg-slate-50 border-slate-200 border-solid border-[1px] rounded-[4px] mt-2">
        <Input
          id="commod-amount"
          placeholder="Commodity Amount (Price 2)"
          type="text"
          value={commodAmount.toString()}
          onChange={handleCommodAmountChange}
        />
      </div>

      <Button
        onClick={approveAsync}
        className="btn btn-primary rounded-full capitalize font-normal font-white w-24 flex items-center gap-1 hover:gap-2 transition-all tracking-widest"
      >
        Approve
      </Button>

      <Button
        onClick={handleConfirm}
        className="btn btn-primary rounded-full capitalize font-normal font-white w-32 flex items-center gap-1 hover:gap-2 transition-all tracking-widest mt-2"
      >
        Confirm
      </Button>
    </div>
  );
};