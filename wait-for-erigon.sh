#!/bin/bash
set -e

ETHEREUM_HOST="http://erigon:8545"
BEACON_HOST="http://erigon:5555"
SLEEP_INTERVAL=15

echo "Waiting for Erigon to be fully synchronized..."

while true; do
    # Check Execution RPC
    if ! curl -s -f -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' "$ETHEREUM_HOST" >/dev/null; then
        echo "Erigon Execution RPC is not yet available. Retrying in $SLEEP_INTERVAL seconds..."
        sleep $SLEEP_INTERVAL
        continue
    fi

    # Check Execution Layer
    EXEC_SYNC_STATUS=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' "$ETHEREUM_HOST")

    if echo "$EXEC_SYNC_STATUS" | grep -q '"result":false'; then
        # Check Beacon API
        if ! curl -s -f "$BEACON_HOST/eth/v1/node/syncing" >/dev/null; then
            echo "Erigon Beacon API is not yet available. Retrying in $SLEEP_INTERVAL seconds..."
            sleep $SLEEP_INTERVAL
            continue
        fi

        # Check Consensus Layer
        BEACON_SYNC_STATUS=$(curl -s "$BEACON_HOST/eth/v1/node/syncing")
        if echo "$BEACON_SYNC_STATUS" | grep -q '"is_syncing":false'; then
            echo "Erigon is fully synchronized! Execution and Consensus layers are ready."
            break
        else
            echo "Erigon Consensus Layer is still syncing. Retrying in $SLEEP_INTERVAL seconds..."
        fi
    else
        echo "Erigon Execution Layer is still syncing. Retrying in $SLEEP_INTERVAL seconds..."
    fi

    sleep $SLEEP_INTERVAL
done
