# law-chain-mvp
MVP for a business proposal designed in "blockchain technologies and cryptocurrencies" course at UFSC. The idea is a hibrid system that uses a traditional database to store files and uses blockchain to keep integrity and auditability of these files.


## Requirements

__*NOTE: This project is based on Ubuntu 22.04. The requirements and steps specified below were not tested in other OSes and may not work on them.*__

Requirement | Version
--- | --- 
docker | 28.2.2 
docker-compose | 1.29.2 
curl | 7.81.0
jq | 1.6
git | latest
tar | 1.34
go | 1.18.1
nodejs | 12.22.9
 
## 1 - Downloading and installing Hyperledger Fabric binaries (v2.5):


Donwload (it is not needed to download anymore as ```install-fabric.sh``` file was added on the project):
```
curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
```

Install:
```
./install-fabric.sh -f 2.5.13 -c 1.5.15
```

## 2 - Execute the ```setup-network.sh``` script
```
./scripts/setup-network.sh
```
This script will:
- Add fabric configurations and fabric binaries to the path
- Generate cryptographic materials (using ```cryptogen```)
- Generate genesis block (using ```configtxgen```)
- Generate channel creation transaction file (using ```configtxgen```)
- Generate anchor peers update transaction files (using ```configtxgen```). In fabric, an ```anchor peer``` is a designated peer in an organization that other peers (from different orgs) can connect to. Anchor peers are how organizations discover and communicate with each other within a channel. Without this, each org’s peers can only communicate within their own org, not across orgs.


## 3 - Starting blockchain network components (orderer and peers)
```
docker-compose -f ./network/docker-compose.yaml up -d
```

## 4 - Entering ```fabric-cli``` container and creating network
```
docker exec -it fabric-cli bash
./scripts/create-network.sh
```
You can get detach the container from your terminal by using the ```exit``` command

## 5 - Removing network (once outside fabric-cli container)
```
./scripts/remove-network.sh
```
Note: if you want to start the blockchain network components again, go back to step 3.

# NOTES

## PHASE 1: Project Planning & Structure

### 1.1 Entities (Organizations)
Each role with decision power typically maps to an organization:

- CollectingOfficerOrg
- CustodianOrg
- ProsecutorOrg
- ForensicOrg
- CourtroomPersonnel will not have an org (read-only, via API).

Each org will have its own MSP (Membership Service Provider) and peer nodes, except CourtroomPersonnel.

### 1.2 Define the Network Topology
Ordering Service: 
- Raft with at least 3 Orderer nodes (best practice).

Peer Nodes:
- 1–2 peers per org (minimum: 1).


