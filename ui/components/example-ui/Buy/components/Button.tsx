import React, { ButtonHTMLAttributes, ReactNode } from 'react';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
    children: ReactNode;
}

export const Button = ({ children }: ButtonProps) => {
    return (
        <button className='
        btn 
        m-auto
        mt-2
        btn-primary 
        rounded-full 
        capitalize 
        font-normal 
        font-white 
        w-4/5
        flex 
        items-center 
        gap-1 
        hover:gap-2 
        transition-all 
        tracking-widest
        '>
            <span>
                {children}
            </span>
        </button>
    );
}
