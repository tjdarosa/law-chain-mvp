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
 
## 1 - Download and install Hyperledger Fabric binaries (v2.5):


Donwload (it is not needed to download anymore as ```install-fabric.sh``` file was added on the project):
```
curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
```

Install:
```
./install-fabric.sh -f 2.5.13 -c 1.5.15
```

## 2 - Go to the test-network dir

```cd ./law-chain-mvp-project/test-network``` 

## 3 - Give permission to execute, and then execute the ```create_full_network.sh``` script

```chmod +x ./create_full_network.sh && ./create_full_network.sh```
This script will:
- take the previous network down (if needed)
- take all existing docker containers down and remove them (to be sure to avoid any conflict)
- start the network with the first two organizations (Collecting Officer and Evidence Custodian)
- create the 'law-channel' channel
- add the remaining 3 organizations to the network (Forensic Analyst, Prosecutor and Courtroom Personnel)

## 4 - Deploy chaincode to the blockchain

```./network.sh deployCC -ccn <chaincode_name> -ccp <chaincode_path> -ccl <chaincode_programming_language [go | java | javascript]>```

Example from Fabric:

```./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-javascript/ -ccl javascript```

## 5 - Execute chaincode

Add the binaries to the path:  
```export PATH=${PWD}/../bin:$PATH```  

Set ```FABRIC_CFG_PATH``` to where ```core.yaml``` is:  
```export FABRIC_CFG_PATH=$PWD/../config/```


Ivoke a chaindode:  
- all peers' addresses and certificates must be passed:
- the two relevant arguments to be changed are ```-n``` (chaincode name) and ```-c``` (function name + args in json format)
```
peer chaincode invoke \
-o localhost:7050 \
--ordererTLSHostnameOverride orderer.example.com \
--tls \
--cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" \
-C law-channel \
--peerAddresses localhost:7051 \
--tlsRootCertFiles "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls/ca.crt" \
--peerAddresses localhost:9051 \
--tlsRootCertFiles "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/tls/ca.crt" \
--peerAddresses localhost:11051 \
--tlsRootCertFiles "${PWD}/organizations/peerOrganizations/forensicanalyst.example.com/peers/peer0.forensicanalyst.example.com/tls/ca.crt" \
--peerAddresses localhost:13051 \
--tlsRootCertFiles "${PWD}/organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/tls/ca.crt" \
--peerAddresses localhost:15051 \
--tlsRootCertFiles "${PWD}/organizations/peerOrganizations/courtroompersonnel.example.com/peers/peer0.courtroompersonnel.example.com/tls/ca.crt" \
-n <chaincode_name> \
-c <function_name_and_args_in_json_format>
```

Example from Fabric:

```
peer chaincode invoke \
-o localhost:7050 \
--ordererTLSHostnameOverride orderer.example.com \
--tls \
--cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" \
-C law-channel \
--peerAddresses localhost:7051 \
--tlsRootCertFiles "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls/ca.crt" \
--peerAddresses localhost:9051 \
--tlsRootCertFiles "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/tls/ca.crt" \
--peerAddresses localhost:11051 \
--tlsRootCertFiles "${PWD}/organizations/peerOrganizations/forensicanalyst.example.com/peers/peer0.forensicanalyst.example.com/tls/ca.crt" \
--peerAddresses localhost:13051 \
--tlsRootCertFiles "${PWD}/organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/tls/ca.crt" \
--peerAddresses localhost:15051 \
--tlsRootCertFiles "${PWD}/organizations/peerOrganizations/courtroompersonnel.example.com/peers/peer0.courtroompersonnel.example.com/tls/ca.crt" \
-n basic \
-c '{"function":"InitLedger","Args":[]}'
```

## Checking containers info

### Which containers were created and are up
```docker ps -a```

### Check container logs
```docker logs <container_name>```  
Executing with ```-f``` will keep the logs running.

### Enter a container to debug/test if needed
```docker exec -it <container_name> bash```

## Taking the network down
```./network.sh down```