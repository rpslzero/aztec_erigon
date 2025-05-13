# It's in-one bundle Aztec Node and Erigon Sepolia Minimal Node with Grafana Dashboard
## What is Aztec?
Aztec is a Privacy-First L2 on Ethereum
On Ethereum today, everything is publicly visible, by everyone. In the real world, people enjoy privacy. Aztec brings privacy to Ethereum.

- private functions, executed and proved on a user's device
- public functions, executed in the Aztec Virtual Machine
- private state, stored as UTXOs that only the owner can decrypt
- public state, stored in a public merkle tree
- composability between private/public execution and private/public state
- public and private messaging with Ethereum
To make this possible, Aztec is not EVM compatible and is extending the Ethereum ecosystem by creating a new alt-VM!

To learn more about how Aztec achieves these things, check out the Aztec concepts overview - https://docs.aztec.network/aztec

## This guide will help you to start all the conteiners, aztec node will wait for full synchronization of erigon node, and as soon as the upper block will be reached, aztec node will start, download backup from Google Cloud and start synchronization with Aztec Network


### It's tested on dedicate server, DONT USE CONTABO servers!!!

## Hardware Requirements

**Minimal Node:**
- At least 4 cores / 8 threads
- 16GB RAM or more
- 512b - NVMe SSD   *Erigon will be use 150Gb (May 2025)*

## First Step
- **Update packages**
    ```
    sudo apt update && sudo apt upgrade -y
    ```
- **Install dependencies**
     ```
     sudo apt install curl build-essential git wget jq make gcc nano tmux -y
     ```
- **Install docker and docker compose**
    ```
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh ./get-docker.sh
    docker version && docker compose version
    ```

- **Run Docker as a non-root user**
- *if you under root can skip this*
    ```
    sudo usermod -aG docker $USER
    ```

### Relogin to your server to take effect from usermod !!!

## Second Step 
- **Clone this repo to your server, navigate to aztec_erigon folder, open .env file with nano and past your Private Key and IP address**
- 
  *Never give your private keys to third parties!!!*
    ```
    git clone https://github.com/andrii1890/aztec_erigon.git
    mkdir -p $HOME/aztec_erigon/data/erigon/
    mkdir -p $HOME/aztec_erigon/data/aztec/
    cd $HOME/aztec_erigon/
    nano .env
    ```
- **Spinup all containers**
    ```
    docker compose up -d
    ```
### Grafana Dashboard will be avaliable here:

- *http://you_ip_address:3000*

### In 4-5 hours check your sync
```
curl -s http://localhost:8080/status
```
### if no result - just wait and try later, if - OK. move next to the https://discord.com/channels/1144692727120937080/1367196595866828982
```
/operator help
```
## Register your node as a Validator
```
docker exec -it aztec \
  node /usr/src/yarn-project/aztec/dest/bin/index.js add-l1-validator \
    --l1-rpc-urls http://erigon:8545 \
    --private-key YOUR PRIVATE KEY \
    --attester YOUR WALLET ADDRESS \
    --proposer-eoa YOUR WALLET ADDRESS \
    --staking-asset-handler 0xF739D03e98e23A7B65940848aBA8921fF3bAc4b2 \
    --l1-chain-id 11155111
```
### Actual finalized block number
```
curl -s -X POST -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","method":"node_getL2Tips","params":[],"id":67}' http://localhost:8080 | jq -r '.result.proven.number'

```

## Third step
- **Add alias for docker logs**
    ```
    echo "#Aztec and Erigon Alias" >> $HOME/.profile
    echo 'alias aztec.log="docker logs aztec -f"' >> $HOME/.profile
    echo 'alias sepolia.log="docker logs erigon -f"' >> $HOME/.profile
    echo 'alias prometheus.log="docker logs prometheus -f"' >> $HOME/.profile
    echo 'alias grafana.log="docker logs grafana -f"' >> $HOME/.profile
    echo 'alias loki.log="docker logs loki -f"' >> $HOME/.profile
    source $HOME/.profile
    ```
    now you can simply find logs: 
    *aztec.log sepolia.log, prometheus.log, grafana.log, loki.log*
  
# You are free to make any changes in docker-compose.yaml if you know what you do 😉
