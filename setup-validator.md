# Setup Validator on Linux
This doc introduce how to setup a humans.ai validator from scratch.All test under ubuntu20.04. You can get much help from official discord channels.

## Minimum hardware requirements for validator

* Memory: **32 GB RAM**
* CPU: **6 cores/12vCores**
* Disk: **500 GB SSD Storage**
* Bandwidth: **1 Gbps for Download/1 Gbps for Upload**

## Environment setup
- prepare development environment for building binaries 
```sh
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git make ncdu -y
```

- install go
<code>
ver="1.20.2" 
cd $HOME 
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" 
sudo rm -rf /usr/local/go 
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" 
rm "go$ver.linux-amd64.tar.gz" 
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> /etc/profile
source /etc/profile
</code>

## Build binaries humansd
<code>
git clone https://github.com/humansdotai/humans.git 
cd humans && git checkout tags/v0.1.0
make install
</code>

## setup your own validator.
- add your account
```sh
humansd keys add <your-account-name> [--keyring-backend os]
```
- init config
```sh
humansd init <your-moniker-name> --chain-id <humans_3000-1>
cd $HOME
wget https://raw.githubusercontent.com/humansdotai/testnets/master/friction/genesis.json
mv genesis.json $HOME/.humansd/config/
```
config seeds and peers from https://github.com/humansdotai/testnets
```sh
SEEDS="xxxxxx"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/" ~/./.humansd/config/config.toml
```

## Syncing
This is optional, 
There are two alternatives for speed up syncing.

### Using state sync

State sync uses light client verification to verify state snapshots from peers
and then apply them. State sync relies on weak subjectivity; a trusted header
(specifically the hash and height) must be provided. 

In `$HOME/.humansd/config/config.toml`, set

```toml
rpc_servers = ""
trust_height = 0
trust_hash = ""
```

to their respective fields. At least two different rpc endpoints should be provided.
The more, the greater the chance of detecting any fraudulent behavior.

Once setup, you should be ready to start the node as normal. In the logs, you should
see: `Discovering snapshots`. This may take a few minutes before snapshots are found
depending on the network topology.

### Using snapshot data

Quick sync effectively downloads the entire `data` directory from a third-party provider
meaning the node has all the application and blockchain state as the node it was
copied from.


```sh
cd $HOME
rm -rf ~/.humansd/data
mkdir -p ~/.humansd/data
wget -O - https://link-for-snapshot/snapshot-name*.tar | tar xf - \
    -C ~/.humansd/data/
```

## Start the humansd
Now you can start you validator
```sh
humansd start
```

## Create validator
### first you need get some token for create validator
If is testnet you can get from official discord faucet channel

### Create validator
```sh
MONIKER="your-moniker-name"
VALIDATOR_WALLET="your account name"

humansd tx staking create-validator \
    --amount=1000000000000000000aheart \
    --pubkey=$(humansd tendermint show-validator) \
    --moniker=<your-moniker-name> \
    --chain-id=humans_3000-1 \
    --commission-rate=0.1 \
    --commission-max-rate=0.2 \
    --commission-max-change-rate=0.01 \
    --min-self-delegation=1 \
    --from=$VALIDATOR_WALLET \
	--details="<your company description>" \
	--security-contact="<your-email-address>" \
	--website="<your website url>" \
	--identity="<your keybase identity>"	
```

### Delgate to validator
Make sure you have enough stake to ensure that you are in the active set
```sh
humansd   tx staking delegate $(humansd keys show <your-monkier-name> --bech=val) <1000000000000000000>aheart --from <account-name>  --fees 200000000000000aheart --chain-id humans_3000-1
```

### check your validator signed latest block
```sh
Status=$(curl localhost:26657/status 2>/dev/null)
validator_address=$(echo $Status |  jq -r .result.validator_info.address)
Height=$(echo $Status | jq -r  .result.sync_info.latest_block_height)
curl localhost:26657/block?height=$Height 2>/dev/null | jq --arg address "$validator_address" '.result.block.last_commit.signatures[] | select(.validator_address == $address)'
```

<!-- sign true or false -->
```sh
Status=$(curl localhost:26657/status 2>/dev/null)
validator_address=$(echo $Status |  jq -r .result.validator_info.address)
Height=$(echo $Status | jq -r  .result.sync_info.latest_block_height)
curl localhost:26657/block?height=$Height 2>/dev/null | jq --arg address "$validator_address" '.result.block.last_commit.signatures[] | select(.validator_address == $address)' | jq 'length != 0' 
```
