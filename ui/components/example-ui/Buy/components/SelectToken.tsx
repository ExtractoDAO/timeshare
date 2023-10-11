import React, { useState, useEffect, useRef } from 'react';
import { IconBusd } from '../../assets/icontoken/busd';
import { IconDai } from '../../assets/icontoken/dai';
import { IconUsdt } from '../../assets/icontoken/usdt';
import { IconUsdc } from '../../assets/icontoken/usdc';

const LisToken = [
  {
    token: 'Tether',
    icon: <IconUsdt className={''} />,
  },
  {
    token: 'Binance USD',
    icon: <IconBusd className={''} />,
  },
  {
    token: 'USD Coin',
    icon: <IconUsdc className={''} />,
  },
  {
    token: 'Dai',
    icon: <IconDai className={''} />,
  },
];

export function SelectToken({ className }: { className?: string }) {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedToken, setSelectedToken] = useState('');

  const dropdownRef = useRef<HTMLDivElement>(null);

  const toggleDropdown = () => {
    setIsOpen((prev) => !prev);
  };

  const handleTokenChange = (event: { target: any; }) => {
    setSelectedToken(event.target.value);
  };

  const selectedTokenItem = LisToken.find((item) => item.token === selectedToken);

  useEffect(() => {
    const handleOutsideClick = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };

    document.addEventListener('click', handleOutsideClick);

    return () => {
      document.removeEventListener('click', handleOutsideClick);
    };
  }, []);

  return (
    <div className='
    inline-block
    m-auto
    mb-2
    '

    >
      <div className='relative' ref={dropdownRef}>
        <button
          onClick={toggleDropdown}
          type='button'
          className='
          flex 
          items-center 
          justify-between 
          input
          font-bai-jamjuree 
          w-full 
          min-w-[130px]
          px-5
          border 
          border-primary 
          text-lg 
          sm:text-2xl 
          placeholder-white 
          uppercase'
        >
          {selectedTokenItem ? (
            <>
              <span className='mr-2'>{selectedTokenItem.icon}</span>
              <span>{selectedTokenItem.token}</span>
            </>
          ) : (
            <span className='text-gray-500'>Select a token</span>
          )}
        </button>
        {isOpen && (
          <div className='
          absolute 
          z-10
          w-full
          border-primary 
          text-xs 
          mt-2 
          bg-white 
          rounded-6
          shadow-lg'
          >
            <ul className='py-1'>
              {LisToken.map((item, i) => (
                <li
                  key={i}
                  onClick={() => {
                    handleTokenChange({ target: { value: item.token } });
                    toggleDropdown();
                  }}
                  className={`
                  flex 
                  items-center 
                  px-4 
                  py-2
                  text-black 
                  cursor-pointer 
                  ${item.token === selectedToken ? 'bg-gray-200' : ''
                    }`}
                >
                  <span className='font-bold'>{item.icon}</span>
                  <span className='ml-2'>{item.token}</span>
                </li>
              ))}
            </ul>
          </div>
        )}
      </div>
    </div>
  );
}
