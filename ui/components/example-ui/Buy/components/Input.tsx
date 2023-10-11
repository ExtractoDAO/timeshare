import React, { InputHTMLAttributes } from "react";

export const Input = (props: InputHTMLAttributes<HTMLInputElement>) => {
  return (
    <div className="relative mt-8 ml-2 mb-2 mr-2">
      <input
        {...props}
        className="
            input
            font-bai-jamjuree 
            w-full 
            px-5
            border 
            border-primary 
            text-lg 
            sm:text-2xl 
            placeholder-white 
            uppercase
            "
      />
      <label
        htmlFor={props?.id}
        className="
            absolute
            left-2
            -top-6
            px-1
            text-[14px]
            text-slate-600
            translate-all"
      >
        {props?.placeholder}
      </label>
    </div>
  );
};
