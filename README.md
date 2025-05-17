Props to OP, changed a few things that worked for me + edited some language.

# All in one Aztec Network Sequencer Node and Erigon Sepolia Minimal Node with Grafana Dashboard
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

## The Aztec node will wait for full synchronization of Erigon node first and as soon as the upper block is reached, the Aztec node will start by downloading backup from Google Cloud and starting synchronization with Aztec Network


### Use a decidated server. If you choose to go with Contabo (which I don't recommend), try the VDS options. Other alternatives would be DigitalOcean, Google Cloud. 

## Hardware Requirements

**Minimal Node:**
- 6 Core+
- Minimum 16GB+ RAM
- 1TB+ NVMe SSD

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
- *if you're root, skip this step*
    ```
    sudo usermod -aG docker $USER
    ```

### Relogin to your server now to take effect from usermod

## Second Step 
- **Clone this repo to your server, navigate to aztec_erigon folder, open .env file with nano and past your Private Key and IP address**
- 
  *Never give your private keys to third parties. You can find your IP with <curl ipv4.icanhazip.com>!!!*
    ```
    git clone https://github.com/andrii1890/aztec_erigon.git
    mkdir -p $HOME/aztec_erigon/data/erigon/
    mkdir -p $HOME/aztec_erigon/data/aztec/
    cd $HOME/aztec_erigon/
    nano .env
    ```
- **Spinup all containers**
    ```bash
    docker compose up -d
    ```
### Grafana Dashboard Accessible Here
- *http://your_ip_address:3000*
  
- *example - http://123.123.123.123:3000*

### Check Sync Status in 4 to 5 hours
    ```
    curl -s http://localhost:8080/status
    ```
    
- *or*
  
    ```
    curl -s -X POST -H 'Content-Type: application/json' \
    -d '{"jsonrpc":"2.0","method":"node_getL2Tips","params":[],"id":67}' \
    http://localhost:8080 | jq -r ".result.proven.number"
    ```
- Check the latest block number of Aztec network: https://aztecscan.xyz/

### Add Alias for Docker Logs

    ```
    echo "#Aztec and Erigon Alias" >> $HOME/.profile
    echo 'alias aztec.log="docker logs aztec -f"' >> $HOME/.profile
    echo 'alias sepolia.log="docker logs erigon -f"' >> $HOME/.profile
    echo 'alias prometheus.log="docker logs prometheus -f"' >> $HOME/.profile
    echo 'alias grafana.log="docker logs grafana -f"' >> $HOME/.profile
    echo 'alias loki.log="docker logs loki -f"' >> $HOME/.profile
    source $HOME/.profile
    ```
    
- Now you can find logs using these commands on your terminal: 
    *aztec.log sepolia.log, prometheus.log, grafana.log, loki.log*

### Get Apprentice Discord Role:
Go to the discord channel :[operators| start-here](https://discord.com/channels/1144692727120937080/1367196595866828982/1367323893324582954) and type /Operator Start. Use the below commands in your terminal to find the information for /block number and /proof. 

**Step 1: Get the latest proven block number:**
```bash
curl -s -X POST -H 'Content-Type: application/json' \
-d '{"jsonrpc":"2.0","method":"node_getL2Tips","params":[],"id":67}' \
http://localhost:8080 | jq -r ".result.proven.number"
```
* Save this block number for the next step
* Example output: 42568

**Step 2: Generate your sync proof**
```bash
curl -s -X POST -H 'Content-Type: application/json' \
-d '{"jsonrpc":"2.0","method":"node_getArchiveSiblingPath","params":["BLOCK_NUMBER","BLOCK_NUMBER"],"id":67}' \
http://localhost:8080 | jq -r ".result"
```
* Replace 2x `BLOCK_NUMBER` with your block number from step 1

**Step 3: Register with Discord**
* Type the following command in this Discord server: `/operator start`
* After typing the command, Discord will display option fields that look like this:
* `address`:           Your validator ETH address
* `block-number`:      Block number from Step 1 above
* `proof`:             base64 string from Step 2 above

Add those details and click enter. Now you will get your `Apprentice` Role

  
## Third step
- **Register your node as a Validator**
- Make sure your Sequencer node is fully synced, before you proceed with Validator registration
- Note: There's a daily quota of 5 validators registration per day, if you get error, try again tommorrow. You can find the timestamp in your error message for the next available slot.
- If your Validator's Registration was successfull, you can check its stats on [Aztec Scan](https://aztecscan.xyz/validators)
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
- Replace `[RPC_URL](http://erigon:8545)`, `YOUR PRIVATE KEY` & 2x `YOUR WALLET ADDRESS`, then proceed

### Sequencer/Validator Checker
* You can use the below Telegram bot to check your validator attestation stats:

https://t.me/aztec_seer_bot

### Verify Node's Peer ID:
**Find your Node's Peer ID:**
```bash
sudo docker logs $(docker ps -q --filter ancestor=aztecprotocol/aztec:alpha-testnet | head -n 1) 2>&1 | grep -i "peerId" | grep -o '"peerId":"[^"]*"' | cut -d'"' -f4 | head -n 1
```
- Copy your node ID from the result and search it on [Nethermind Explorer](https://aztec.nethermind.io/)
- It will take time to show up in the Nethermind Explorer. If your node is synced and running, check back later.
