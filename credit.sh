#!/bin/bash

FOLDER_PATH="./friction/mission-3/gentxs"

for FILE_PATH in "$FOLDER_PATH"/*.json; do
  DELEGATOR_ADDRESS=$(jq -r '.. | .delegator_address? // empty' "$FILE_PATH")
  if [ -n "$DELEGATOR_ADDRESS" ]; then
    COMMAND="humansd add-genesis-account $DELEGATOR_ADDRESS 1040000000000000000aheart"
    echo "Executing command: $COMMAND"
    # Uncomment the following line to execute the command
    $COMMAND
    echo "------------------------"
  fi
done
