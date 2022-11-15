#!/usr/bin/env bash

repeat() {
  local n=$1
  shift
  for ((i=0; i<n; i++)); do
    "$@"
  done
}

repeat 7 flow accounts create \
  --network emulator \
  --key 6e1bfdf4da1e5c1930465c8bbe0af3ca398cc252e824dd224c79e4d2111c5a7c36a7099f9019f46df4fb9903939c083fe8409e8899af0a05fbbfe8d994569f23

flow project deploy --network emulator