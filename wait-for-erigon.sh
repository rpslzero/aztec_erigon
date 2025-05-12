#!/bin/bash
set -e

ETHEREUM_HOST="${ETHEREUM_HOSTS:-http://erigon:8545}"
BEACON_HOST="${L1_CONSENSUS_HOST_URLS:-http://erigon:5555}"
SLEEP_INTERVAL=15

echo "ETHEREUM_HOST: $ETHEREUM_HOST"
echo "BEACON_HOST: $BEACON_HOST"
echo "Waiting for Erigon to be fully synchronized..."

while true; do
    # Проверка доступности Execution RPC
    if ! curl -s -f -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' "$ETHEREUM_HOST" >/dev/null; then
        echo "Erigon Execution RPC is not yet available. Retrying in $SLEEP_INTERVAL seconds..."
        sleep $SLEEP_INTERVAL
        continue
    fi

    # Проверка статуса синхронизации Execution Layer
    EXEC_SYNC_STATUS=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' "$ETHEREUM_HOST")
    echo "Execution Sync Status: $EXEC_SYNC_STATUS"

    if echo "$EXEC_SYNC_STATUS" | grep -q '"result":false'; then
        # Проверка доступности Beacon API
        if ! curl -s -f "$BEACON_HOST/eth/v1/node/syncing" >/dev/null; then
            echo "Erigon Beacon API is not yet available. Retrying in $SLEEP_INTERVAL seconds..."
            sleep $SLEEP_INTERVAL
            continue
        fi

        # Проверка статуса синхронизации Consensus Layer
        BEACON_SYNC_STATUS=$(curl -s "$BEACON_HOST/eth/v1/node/syncing")
        echo "Beacon Sync Status: $BEACON_SYNC_STATUS"
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

echo "Erigon synchronization complete. Exiting script to allow Aztec to start..."
