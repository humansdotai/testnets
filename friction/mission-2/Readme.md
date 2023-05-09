# Mission 2 

# Submitting your gentx for the Humans Incentivized Testnet

## Prerequisites

* [Overview](../../Readme.md)
* [Installation Instructions](../../Install.md)
* [Node repository](https://github.com/humansdotai/humans/)

⚠️ Check the `genesis.json` hash before continuing `be45acc413ef1ff73a19c796e74b84acdeb65b14d672684dc2374889c898cd3d  genesis.json`

Thank you for becoming a genesis validator on Humans! This guide will provide instructions on setting up a node, submitting a gentx, and other tasks needed to participate in the launch of the Humans Friction incentivized testnet.

A `gentx` does three things:

* Registers the validator account you created as a validator operator account (i.e. the account that controls the validator).
* Self-delegates the provided amount of staking tokens.
* Links the operator account with a Tendermint node pubkey that will be used for signing blocks. If no `--pubkey` flag is provided, it defaults to the local node pubkey created via the `humansd init` command.

## Setup

Software:

* Go version: [v1.20.1+](https://golang.org/dl/)
* Humans version: [v0.2.1](https://github.com/humansdotai/humans/releases)

To verify that Go is installed:

```sh
go version
# Should return go version go1.20.1 linux/amd64
```

## Instructions

These instructions are written targeting an Ubuntu 20.04 system.  Relevant changes to commands should be made depending on the OS/architecture you are running on.

1. Install `humansd`

   ```bash
   git clone https://github.com/humansdotai/humans
   cd humans && git checkout tags/v0.2.1
   make install
   ```

   If the `humansd` command is not available you can copy `cp ./build/humansd /usr/local/sbin/` you might need `sudo`

   Make sure to checkout to `v0.2.1` tag.

   Verify that everything is OK. If you get something *like* the following, you've successfully installed Humans on your system.

   ```sh
   build_tags: netgo ledger,
   commit: d773227063e5d6187bfc312b2cf42fc18f4533e0
   cosmos_sdk_version: v0.46.11
   go: go version go1.20.3 linux/amd64
   name: humans
   server_name: humansd
   version: 0.2.1
   ```

2. Initialize the `humansd` directories and create the local file with the correct chain-id

   ```bash
   humansd init <moniker> --chain-id=humans_3000-23
   ```

3. Create a local key pair in the keybase

   ```bash
   humansd keys add <your key name>
   ```

   Make sure to keep mnemonic seed which will be used to receive rewards at the time of mainnet launch.

4. Add the account to your local genesis file with a given amount and key you just created.

   ```bash
   humansd add-genesis-account $(humansd keys show <your key name> -a) 1000000000000000000aheart
   ```

   Make sure to use `aheart` denom, not anything else like `uatom`.

5. Create the gentx

   ⚠️ Please set the `commission-rate` ≥ `0.05` as the genesis parameter for staking `min_commission_rate` is set to `0.05` and the genesis block will not be generated.

     ⚠️ Please set the `gas-prices` ≥ `4000000000000000aheart` as the global parameter for  `gas-prices` is set to be bigger than `4000000000000000aheart` and the gentx creation will fail thus block will not co generated.

   ```bash
   humansd gentx <your key name> 1000000000000000000aheart \
     --chain-id=humans_3000-23 \
     --moniker=<moniker> \
     --details="My moniker description" \
     --commission-rate=0.05 \
     --commission-max-rate=0.2 \
     --commission-max-change-rate=0.01 \
     --gas-prices 4000000000000000aheart \
     --pubkey $(humansd tendermint show-validator) \
     --identity="<Keybase.io GPG Public Key>"
   ```

   ⚠️ If you are going to use the `--port` and `--ip` option to set a custom `port/ip` for your validator be sure that settings match inside the `config.toml` for your validator node
6. Collect the gentx

    ```bash
    humansd collect-gentxs
    ```

7. Validate the genesis

    ```bash
    humansd validate-genesis
    ```

8 . Create Pull Request to the repository ([humansdotai/testnets](https://github.com/humansdotai/testnets)) with the file  `friction/mission-2/gentxs/<your validator moniker>.json`. In order to be a valid submission, you need the `.json` file extension and no whitespace or special characters in your filename.

Your PR should be one addition. Only PR requests from approved active participants will be included in the genesis file.

## Seed and Peers

We are expecting that the peers in the genesis files are reachable, so we can avoid resynchronization issues, or unreachable genesis peers in the future, if you are behind a NAT or a private infrastructure please use the `--ip` and the `--port` flag when generating the gentx file.
