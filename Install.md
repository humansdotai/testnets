# Run a Validator

## Create Your Validator

Your node consensus public key (`humanvalconspub...`) can be used to create a new validator by staking `$HEART` tokens. You can find your validator pubkey by running:

```bash
humansd tendermint show-validator
```

**DANGER**: Never create your mainnet validator keys using a `test` keying backend. Doing so might result in a loss of funds by making your funds remotely accessible via the `eth_sendTransaction` JSON-RPC endpoint.

Ref: [Security Advisory: Insecurely configured geth can make funds remotely accessible](https://blog.ethereum.org/2015/08/29/security-alert-insecurely-configured-geth-can-make-funds-remotely-accessible/)

To create your validator on testnet, just use the following command:

```bash
humansd tx staking create-validator \
  --amount=1000000000000000000aheart \
  --pubkey=$(humansd tendermint show-validator) \
  --moniker="choose a moniker" \
  --chain-id=<chain_id> \
  --commission-rate="0.05" \
  --commission-max-rate="0.10" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1000000" \
  --gas="auto" \
  --gas-prices="1800000000aheart" \
  --from=<key_name>
```

When specifying commission parameters, the `commission-max-change-rate` is used to measure % *point* change over the `commission-rate`. E.g. 1% to 2% is a 100% rate increase, but only 1 percentage point.

`min-self-delegation` is a strictly positive integer that represents the minimum amount of self-delegated voting power your validator must always have. A `min-self-delegation` of `1000000000000000000aheart` means your validator will never have a self-delegation lower than `1 $HEART`

You can confirm that you are in the validator set by using a third party explorer.

## Edit Validator Description

You can edit your validator's public description. This info is to identify your validator, and will be relied on by delegators to decide which validators to stake to. Make sure to provide input for every flag below. If a flag is not included in the command the field will default to empty (`--moniker` defaults to the machine name) if the field has never been set or remain the same if it has been set in the past.

The <key_name> specifies which validator you are editing. If you choose to not include certain flags, remember that the --from flag must be included to identify the validator to update.

The `--identity` can be used as to verify identity with systems like Keybase or UPort. When using with Keybase `--identity` should be populated with a 16-digit string that is generated with a [keybase.io](https://keybase.io) account. It's a cryptographically secure method of verifying your identity across multiple online networks. The Keybase API allows us to retrieve your Keybase avatar. This is how you can add a logo to your validator profile.

```bash
humansd tx staking edit-validator
  --moniker="<your_moniker>" \
  --website="https://humans.ai" \
  --identity=<your_keybase_identity> \
  --details="To infinity and beyond!" \
  --chain-id=<chain_id> \
  --gas="auto" \
  --gas-prices="1800000000aheart" \
  --from=<key_name> \
  --commission-rate="0.10"
```

**Note**: The `commission-rate` value must adhere to the following invariants:

* Must be between 0 and the validator's `commission-max-rate`
* Must not exceed the validator's `commission-max-change-rate` which is maximum
  % point change rate **per day**. In other words, a validator can only change
  its commission once per day and within `commission-max-change-rate` bounds.

## View Validator Description

View the validator's information with this command:

```bash
humansd query staking validator <account_cosmos>
```

## Track Validator Signing Information

In order to keep track of a validator's signatures in the past you can do so by using the `signing-info` command:

```bash
humansd query slashing signing-info <validator-pubkey>\
  --chain-id=<chain_id>
```

## Unjail Validator

When a validator is "jailed" for downtime, you must submit an `Unjail` transaction from the operator account in order to be able to get block proposer rewards again (depends on the zone fee distribution).

```bash
humansd tx slashing unjail \
  --from=<key_name> \
  --chain-id=<chain_id>
```

## Confirm Your Validator is Running

Your validator is active if the following command returns anything:

```bash
humansd query tendermint-validator-set | grep "$(humansd tendermint show-address)"
```

You should now see your validator in one of Evmos explorers. You are looking for the `bech32` encoded `address` in the `~/.humansd/config/priv_validator.json` file.

**Note**
To be in the validator set, you need to have more total voting power than the 100th validator.
:::

## Halting Your Validator

When attempting to perform routine maintenance or planning for an upcoming coordinated
upgrade, it can be useful to have your validator systematically and gracefully halt.
You can achieve this by either setting the `halt-height` to the height at which
you want your node to shutdown or by passing the `--halt-height` flag to `humansd`.
The node will shutdown with a zero exit code at that given height after committing
the block.

## Common Problems

### Problem #1: My validator has `voting_power: 0`

Your validator has become jailed. Validators get jailed, i.e. get removed from the active validator set, if they do not vote on `500` of the last `10000` blocks, or if they double sign.

If you got jailed for downtime, you can get your voting power back to your validator. First, if `humansd` is not running, start it up again:

```bash
humansd start
```

Wait for your full node to catch up to the latest block. Then, you can [unjail your validator](#unjail-validator)

Lastly, check your validator again to see if your voting power is back.

```bash
humansd status
```

You may notice that your voting power is less than it used to be. That's because you got slashed for downtime!

### Problem #2: My node crashes because of `too many open files`

The default number of files Linux can open (per-process) is `1024`. `humansd` is known to open more than `1024` files. This causes the process to crash. A quick fix is to run `ulimit -n 4096` (increase the number of open files allowed) and then restart the process with `humansd start`. If you are using `systemd` or another process manager to launch `humansd` this may require some configuration at that level. A sample `systemd` file to fix this issue is below:

```toml
# /etc/systemd/system/humansd.service
[Unit]
Description=Humans Friction Node
After=network.target

[Service]
Type=simple
User=<your_user>
WorkingDirectory=/home/<your_user>
ExecStart=/home/<your_user>/go/bin/humansd start
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
```

## Configuration changes for optimization and metrics

The script makes the following changes to the configuration files:

* Disables producing empty blocks.
* Enables Prometheus metrics.

The changes are made using sed commands, which are used to search and replace text in a file. The script uses sed to replace the values of the following parameters in the `config.toml` file:

```toml
create_empty_blocks = true
prometheus = false
```

These values are replaced with the following:

```toml
create_empty_blocks = false
prometheus = true
```

The script also makes changes to the following parameters in the `app.toml` file:

```toml
prometheus-retention-time = 0
enabled = false
```

These values are replaced with the following:

```toml
prometheus-retention-time = 1000000000000
enabled = true
```

If the script is called with the argument "pending", it makes additional changes to the configuration to wait for the first block to be committed.

The script uses sed to replace the values of the following parameters in the `config.toml` file:

```toml
create_empty_blocks_interval = "0s"
timeout_propose = "3s"
timeout_propose_delta = "500ms"
timeout_prevote = "1s"
timeout_prevote_delta = "500ms"
timeout_precommit = "1s"
timeout_precommit_delta = "500ms"
timeout_commit = "5s"
timeout_broadcast_tx_commit = "10s"
```

These values are replaced with the following:

```toml
create_empty_blocks_interval = "30s"
timeout_propose = "30s"
timeout_propose_delta = "5s"
timeout_prevote = "10s"
timeout_prevote_delta = "5s"
```

## Exposing ports

This will allow you to expose different API and RPC ports, and configure CORS (Cross-Origin Resource Sharing) to manage the security of your network. Here's a step-by-step tutorial on how to expose the different API and RPC ports and configure CORS on Humans blockchain by editing the configuration files:

### Expose the Node API

 To do this, edit the following lines of the `app.toml` configuration file:

```bash
###############################################################################
###                           API Configuration                             ###
###############################################################################

[api]

# Enable defines if the API server should be enabled.
enable = true

# Swagger defines if swagger documentation should automatically be registered.
swagger = true

# Address defines the API server to listen on.
address = "tcp://0.0.0.0:1317"

# MaxOpenConnections defines the number of maximum open connections.
max-open-connections = 100

# RPCReadTimeout defines the Tendermint RPC read timeout (in seconds).
rpc-read-timeout = 5

# RPCWriteTimeout defines the Tendermint RPC write timeout (in seconds).
rpc-write-timeout = 3

# RPCMaxBodyBytes defines the Tendermint maximum response body (in bytes).
rpc-max-body-bytes = 1000000

# EnableUnsafeCORS defines if CORS should be enabled (unsafe - use it at your own risk).
enabled-unsafe-cors = false
```

### Expose the Node RPC

 To do this, edit the following lines of the `config.toml` configuration file:

```bash
#######################################################
###       RPC Server Configuration Options          ###
#######################################################
[rpc]

# TCP or UNIX socket address for the RPC server to listen on
laddr = "tcp://0.0.0.0:26657"

# A list of origins a cross-domain request can be executed from
# Default value '[]' disables cors support
# Use '["*"]' to allow any origin
cors_allowed_origins = ["*.humans.ai","*.humans.zone"]

# A list of methods the client is allowed to use with cross-domain requests
cors_allowed_methods = ["HEAD", "GET", "POST", ]

# A list of non simple headers the client is allowed to use with cross-domain requests
cors_allowed_headers = ["Origin", "Accept", "Content-Type", "X-Requested-With", "X-Server-Time", ]

```

### Expose the Node P2P Port

To do this, edit the following lines of the `config.toml` configuration file:

```bash
#######################################################
###           P2P Configuration Options             ###
#######################################################
[p2p]

# Address to listen for incoming connections
laddr = "tcp://0.0.0.0:26656"

# Address to advertise to peers for them to dial
# If empty, will use the same port as the laddr,
# and will introspect on the listener or use UPnP
# to figure out the address. ip and port are required
# example: 159.89.10.97:26656
external_address = "<your_external_address>"
```

### Expose the Node EVM RPC, WS, Metrics

To do this, edit the following lines of the `app.toml` configuration file:

```bash
###############################################################################
###                           JSON RPC Configuration                        ###
###############################################################################

[json-rpc]

# Enable defines if the gRPC server should be enabled.
enable = true

# Address defines the EVM RPC HTTP server address to bind to.
address = "0.0.0.0:8545"

# Address defines the EVM WebSocket server address to bind to.
ws-address = "0.0.0.0:8546"

# API defines a list of JSON-RPC namespaces that should be enabled
# Example: "eth,txpool,personal,net,debug,web3"
api = "eth,net,web3"

# GasCap sets a cap on gas that can be used in eth_call/estimateGas (0=infinite). Default: 25,000,000.
gas-cap = 25000000

# EVMTimeout is the global timeout for eth_call. Default: 5s.
evm-timeout = "5s"

# TxFeeCap is the global tx-fee cap for send transaction. Default: 1eth.
txfee-cap = 1

# FilterCap sets the global cap for total number of filters that can be created
filter-cap = 200

# FeeHistoryCap sets the global cap for total number of blocks that can be fetched
feehistory-cap = 100

# LogsCap defines the max number of results can be returned from single 'eth_getLogs' query.
logs-cap = 10000

# BlockRangeCap defines the max block range allowed for 'eth_getLogs' query.
block-range-cap = 10000

# HTTPTimeout is the read/write timeout of http json-rpc server.
http-timeout = "30s"

# HTTPIdleTimeout is the idle timeout of http json-rpc server.
http-idle-timeout = "2m0s"

# AllowUnprotectedTxs restricts unprotected (non EIP155 signed) transactions to be submitted via
# the node's RPC when the global parameter is disabled.
allow-unprotected-txs = false

# MaxOpenConnections sets the maximum number of simultaneous connections
# for the server listener.
max-open-connections = 0

# EnableIndexer enables the custom transaction indexer for the EVM (ethereum transactions).
enable-indexer = false

# MetricsAddress defines the EVM Metrics server address to bind to. Pass --metrics in CLI to enable
# Prometheus metrics path: /debug/metrics/prometheus
metrics-address = "0.0.0.0:6065"

# Upgrade height for fix of revert gas refund logic when transaction reverted.
fix-revert-gas-refund-height = 0
```

### Expose Node metrics

To do this, edit the following lines of the `config.toml` configuration file:

```bash
#######################################################
###       Instrumentation Configuration Options     ###
#######################################################
[instrumentation]

# When true, Prometheus metrics are served under /metrics on
# PrometheusListenAddr.
# Check out the documentation for the list of available metrics.
prometheus = true

# Address to listen for Prometheus collector(s) connections
prometheus_listen_addr = ":26660"

# Maximum number of simultaneous connections.
# If you want to accept a larger number than the default, make sure
# you increase your OS limits.
# 0 - unlimited.
max_open_connections = 3

# Instrumentation namespace
namespace = "cometbft"
```

### Expose ABCI proxy

To do this, edit the following lines of the `config.toml` configuration file:

```bash
#######################################################################
###                   Main Base Config Options                      ###
#######################################################################

# TCP or UNIX socket address of the ABCI application,
# or the name of an ABCI application compiled in with the CometBFT binary
proxy_app = "tcp://0.0.0.0:26658"

# A custom human readable name for this node
moniker = "my_moniker"
```

* Restart the Humans blockchain:
The final step is to restart the Humans blockchain to apply the changes.
That's it! You have successfully exposed the API and RPC ports and configured CORS on your Humans blockchain. Now, you can access your API and RPC ports from the domain that you specified in the CORS configuration.

# Starting the node

We recommend starting the node with the following parameters

```bash
humansd start --home <your_data_dir> --chain-id <your_chain_id> --metrics --pruning=nothing --evm.tracer=json --minimum-gas-prices=1800000000aheart json-rpc.api eth,net,web3,miner --api.enable
```
