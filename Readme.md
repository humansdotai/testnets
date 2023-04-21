# Overview

## Validating on Humans

Humans is based on [CometBFT](https://github.com/cometbft/cometbft), which relies on a set of validators that are responsible for committing new blocks in the blockchain. These validators participate in the consensus protocol by broadcasting votes which contain cryptographic signatures signed by each validator's private key.

Validator candidates can bond their own staking tokens and have the tokens "delegated", or staked, to them by token holders. The Humans is Humans's native token. At its onset, Humans launched with 50 validators. The validators are determined by who has the most stake delegated to them - the top 50 validator candidates with the most stake become part of the active Humans validator set.

Validators and their delegators will earn `$HEART` as block provisions and tokens as transaction fees through execution of the Tendermint consensus protocol. Initially, transaction fees will be paid in `$HEART` but in the future, any token in the Cosmos ecosystem will be valid as fee tender if it is whitelisted by governance. Note that validators can set commission on the fees their delegators receive as additional incentive that must be equal or greater than 5%.

## Pitfalls

If validators double sign, are frequently offline or do not participate in governance, their staked `$HEART` (including `$HEART` of users that delegated to them) can be slashed. The penalty depends on the severity of the violation.

## Hardware

Validators should set up a physical operation secured with restricted access. A good starting place, for example, would be co-locating in secure data centers.

Validators should expect to equip their datacenter location with redundant power, connectivity, and storage backups. Expect to have several redundant networking boxes for fiber, firewall and switching and then small servers with redundant hard drive and failover. Hardware can be on the low end of datacenter gear to start out with.

We anticipate that network requirements will be low initially. Bandwidth, CPU and memory requirements will rise as the network grows. Large hard drives are recommended for storing years of blockchain history.

### Supported OS

We officially support Linux (Ubuntu, Debian and CentOS latest stable distributions) only in the following architectures:

- `linux/arm64`
- `linux/amd64`

### Minimum Requirements

To run mainnet or testnet validator nodes, you will need a machine with the following minimum hardware requirements:

- 6 or more physical CPU cores
- At least 500GB of SSD disk storage
- At least 32GB of memory (RAM)
- At least 1000mbps network bandwidth

As the usage of the blockchain grows, the server requirements may increase as well, so you should have a plan for updating your server as well.

## Get Involved

Set up a dedicated validator's website, social profile (e.g., Twitter), and signal your intention to become a validator on Discord. This is important since users will want to have information about the entity they are staking their Humans to.

## Community

Discuss the finer details of being a validator and seek advice from the rest of the validator community on our [Discord](https://discord.gg/humansdotai).
