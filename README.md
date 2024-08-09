# Flow Bridged USDC

This repo holds the `USDCFlow` smart contract, the Cadence 
Fungible Token contract that acts as the Cadence bridged version of
Flow EVM USDC.

# What is Flow?

Flow is the blockchain for open worlds. Read more about it [here](https://www.flow.com/).

# What is Cadence?

Cadence is a Resource-oriented programming language 
for developing smart contracts for the Flow Blockchain.
Read more about it [here](https://www.cadence-lang.org)

We recommend that anyone who is reading this should have already
completed the [Cadence Tutorials](https://cadence-lang.org/docs/tutorial/first-steps) 
so they can build a basic understanding of the programming language.

# USDCFlow

`contracts/USDCFlow.cdc`

| Network       | Contract Address     |
| ------------- | -------------------- |
| Previewnet    | Coming Soon |
| Testnet       | [`0x4516677f8083d680`](https://contractbrowser.com/A.4516677f8083d680.USDCFlow) |
| Mainnet       | [`0xf1ab99c82dee3526`]() |

This is the contract that defines the Cadence version of Flow USDC. 
Before the Sept 4th Crescendo migration, users can send
old `FiatToken` vaults to the `USDCFlow.wrapFiatToken()` function
and receive `USDCFlow` vaults back with the exact same balance.

After the Crescendo migration, the `USDCFlow` smart contract
will integrate directly with the Flow VM bridge to become
the bridged version of Flow EVM USDC. These tokens will be backed
by real USDC via Flow EVM, so they will retain their value.

This contract will be deployed to a different address
and have a different name than the original `FiatToken`,
so contracts that want to continue to support USDC on Flow
will need to migrate their code and state to the new `USDCFlow`
smart contract.

You can see a guide for how to migrate to the `USDCFlow` contract
in the [Cadence 1.0 Migration Guide](https://cadence-lang.org/docs/cadence-migration-guide/).

You can find transactions and scripts for interacting with the `USDCFlow` contract in the `transactions/` directory.

# Local Development

The contract in this repo is not yet included in the Flow emulator.
If you want to use this contract with the emulator,
you must add it to your `flow.json` and deploy it yourself.

As is, the contract can only mint new USDC if an old `FiatToken.Vault`
is passed into the `wrapFiatToken()` function. If you want to 
test with this token on the emulator, you'll either need
to deploy the simplified version of `FiatToken`
in this repo and mint and wrap tokens,
or you will need to uncomment the lines of code
in the `init()` function to mint tokens during deployment.

### Prerequisites

- Install Flow CLI on your machine. For instructions, see the [Flow CLI documentation](https://developers.flow.com/tools/flow-cli/install).

Ensure it is installed with:

```sh
flow version
```

### Run the Tests

To run the tests in this repo, simply navigate
to the root directory and run `make test`.
That will run all the tests in the `tests/` directory.

### Additional Resources

- [Old `FiatToken` code](https://github.com/flow-usdc/flow-usdc)
- [Blog Post Announcing Migration from old USDC to new USDC](https://www.flow.com/post/stablecoins-on-flow-evolving-for-interoperability)
- [Flow VM Bridge Github Repo](https://github.com/onflow/flow-evm-bridge/tree/main)