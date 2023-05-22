#!/bin/bash

folder="/Volumes/code/humans/testnets/friction/mission-2/gentxs"
chain_id="humans_3000-23"
key_name="staking"
sequence=$(humansd query account "$(humansd keys show "$key_name" -a --keyring-backend test)" --node https://rpc.friction.humans.zone:443 --output json | jq -r '.base_account.sequence')

for file in "$folder"/*.json; do
  validator_address=$(jq -r '.body.messages[].validator_address' "$file")
  echo "Delegating to $validator_address"
  humansd tx staking delegate "$validator_address" 998997000000000000000000aheart --from "$key_name" --chain-id "$chain_id" --keyring-backend test --node https://rpc.friction.humans.zone:443 --sequence "$sequence" --yes
  sequence=$((sequence + 1))
done
