# law-chain-mvp
MVP for a business proposal designed in "blockchain technologies and cryptocurrencies" course at UFSC. The idea is a hibrid system that uses a traditional database to store files and uses blockchain to keep integrity and auditability of these files.


## Requirements

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
 
- It is also needed to download and install Hyperledger Fabric binaries (v2.5):

Donwload:
```
curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
```
Install:
```
./install-fabric.sh -f 2.5.13 -c 1.5.15
```




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





