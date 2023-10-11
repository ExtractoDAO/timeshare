# Documentation about decisions

## Context

We need a DeFi who can sell **contracts**.

## Decision

Development based on BDD using foundry and solidity

Create a parent contract "ExtractDao" that:
    - creates new contracts (Future)
    - has the payment logic

Create a child contract "Future" which:
    - is created by the parent contract
    - contains the DeFi logic

| Argumento | Solidity ✅ | Vyper | Rust/ink! |
| - | - | - | - |
| Documentation | high | medium | poor |
| mainnet projects | high | medium | poor |
| difficult | medium | poor | high |
| toolchain | high | poor | poor |
| VM based | EVM | EVM | Wasm |

| Argumento | Hardhat | Foundry ✅ | Truffle |
| - | - | - | - |
| Documentation | medium | high | high |
| mainnet projects | high | medium | high |
| difficult | poor | high | poor |
| speed | slow | fast | slow |
| lang based | typescript | rust | javascript |
| lang use for tests | typescript | solidity | javascript |

## Consequences

- We started using hardhat for e2e tests and foundry for unit tests.
- After gaining expertise with foundry all tests were migrated to foundry and hardhat was removed.
- Working with Solmate or OpenZeppelin became complicated to manage, and the usage was too low for the cost of maintaining third party libraries.
