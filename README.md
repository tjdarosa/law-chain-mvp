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

## 2 - Go to the test-network dir

```
cd ./law-chain-mvp-project/test-network
``` 

## 3 - Start the network with the all organizations + orderer and create the channel "law-channel"

```
chmod +x ./scripts/setup_network.sh && ./scripts/setup_network.sh
``` 

## 4. Initialize Go Module

```
cd ./chaincode-go
go mod init lawchain
go mod tidy
```

## 5. Add Fabric binaries to your PATH

```
cd ../../../fabric-samples/bin
export PATH=$PATH:$(pwd)
```

## 6. Return to test-network and package the chaincode

```
cd ../../law-chain-mvp-project/test-network
export FABRIC_CFG_PATH=~/fabric-config
peer lifecycle chaincode package lawchain_1.0.tar.gz --path ./chaincode-go --lang golang --label lawchain_1.0
```

You should now have `lawchain_1.0.tar.gz` in the current directory.

## 7. Install the chaincode on each peer

### For `peer0.prosecutor.example.com`

```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="ProsecutorMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/prosecutor.example.com/users/Admin@prosecutor.example.com/msp
export CORE_PEER_ADDRESS=localhost:13051

peer lifecycle chaincode install lawchain_1.0.tar.gz
```

### For `peer0.courtroompersonnel.example.com`

```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="CourtroomPersonnelMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/courtroompersonnel.example.com/peers/peer0.courtroompersonnel.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/courtroompersonnel.example.com/users/Admin@courtroompersonnel.example.com/msp
export CORE_PEER_ADDRESS=localhost:15051

peer lifecycle chaincode install lawchain_1.0.tar.gz
```

### For `peer0.forensicanalyst.example.com`

```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="ForensicAnalystMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/forensicanalyst.example.com/peers/peer0.forensicanalyst.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/forensicanalyst.example.com/users/Admin@forensicanalyst.example.com/msp
export CORE_PEER_ADDRESS=localhost:11051

peer lifecycle chaincode install lawchain_1.0.tar.gz
```

### For `peer0.collectingofficer.example.com`

```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="CollectingOfficerMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/collectingofficer.example.com/users/Admin@collectingofficer.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer lifecycle chaincode install lawchain_1.0.tar.gz
```

### For `peer0.evidencecustodian.example.com`

```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="EvidenceCustodianMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/users/Admin@evidencecustodian.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

peer lifecycle chaincode install lawchain_1.0.tar.gz
```

## 8. Approve the chaincode for each organization

### For `peer0.prosecutor.example.com`
```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="ProsecutorMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/prosecutor.example.com/users/Admin@prosecutor.example.com/msp
export CORE_PEER_ADDRESS=localhost:13051

peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID law-channel --name lawchain --version 1.0 --package-id lawchain_1.0:f3ae32ca8f026059de295a45ce782426f08808c8fcf3defe41819d6b7c86d432 --sequence 1
```


### For `peer0.courtroompersonnel.example.com`
```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="CourtroomPersonnelMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/courtroompersonnel.example.com/peers/peer0.courtroompersonnel.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/courtroompersonnel.example.com/users/Admin@courtroompersonnel.example.com/msp
export CORE_PEER_ADDRESS=localhost:15051

peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID law-channel --name lawchain --version 1.0 --package-id lawchain_1.0:f3ae32ca8f026059de295a45ce782426f08808c8fcf3defe41819d6b7c86d432 --sequence 1
```

### For `peer0.forensicanalyst.example.com`
```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="ForensicAnalystMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/forensicanalyst.example.com/peers/peer0.forensicanalyst.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/forensicanalyst.example.com/users/Admin@forensicanalyst.example.com/msp
export CORE_PEER_ADDRESS=localhost:11051

peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID law-channel --name lawchain --version 1.0 --package-id lawchain_1.0:f3ae32ca8f026059de295a45ce782426f08808c8fcf3defe41819d6b7c86d432 --sequence 1
```

### For `peer0.collectingofficer.example.com`
```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="CollectingOfficerMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/collectingofficer.example.com/users/Admin@collectingofficer.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID law-channel --name lawchain --version 1.0 --package-id lawchain_1.0:f3ae32ca8f026059de295a45ce782426f08808c8fcf3defe41819d6b7c86d432 --sequence 1
```

### For `peer0.evidencecustodian.example.com`
```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="EvidenceCustodianMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/users/Admin@evidencecustodian.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem --channelID law-channel --name lawchain --version 1.0 --package-id lawchain_1.0:f3ae32ca8f026059de295a45ce782426f08808c8fcf3defe41819d6b7c86d432 --sequence 1
```

## 9. Commit the chaincode definition

```
peer lifecycle chaincode commit \
  --channelID law-channel \
  --name lawchain \
  --version 1.0 \
  --sequence 1 \
  --tls \
  --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  --peerAddresses localhost:13051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/tls/ca.crt \
  --peerAddresses localhost:7051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls/ca.crt \
  --peerAddresses localhost:11051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/forensicanalyst.example.com/peers/peer0.forensicanalyst.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/tls/ca.crt \
  --peerAddresses localhost:15051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/courtroompersonnel.example.com/peers/peer0.courtroompersonnel.example.com/tls/ca.crt
```

### Verify commit

```
peer lifecycle chaincode querycommitted \
  --channelID law-channel \
  --name lawchain \
  --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

## 10. Invoke a transaction

```
peer chaincode invoke \
  -o localhost:7050 \
  --ordererTLSHostnameOverride orderer.example.com \
  --tls \
  --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \
  -C law-channel \
  -n lawchain \
  --peerAddresses localhost:13051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/tls/ca.crt \
  --peerAddresses localhost:7051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls/ca.crt \
  --peerAddresses localhost:11051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/forensicanalyst.example.com/peers/peer0.forensicanalyst.example.com/tls/ca.crt \
  --peerAddresses localhost:9051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/tls/ca.crt \
  --peerAddresses localhost:15051 \
  --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/courtroompersonnel.example.com/peers/peer0.courtroompersonnel.example.com/tls/ca.crt \
  -c '{"function":"StoreEvidence","Args":["EV123","abf345c9...hash","Prosecutor","Knife found at crime scene","knife.jpg","<signature_base64>","<public_key_base64>"]}'
```

## 11. Query the chaincode

Export peer environment (e.g., for Prosecutor):

```
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="ProsecutorMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/prosecutor.example.com/users/Admin@prosecutor.example.com/msp
export CORE_PEER_ADDRESS=localhost:13051
```

Then run the query:

```
peer chaincode query \
  -C law-channel \
  -n lawchain \
  -c '{"function":"ReadEvidence","Args":["EV123"]}'
```

## 12 - Checking containers info

### Which containers were created and are up
```
docker ps -a
```

### Check container logs
```
docker logs <container_name>
```  
Executing with ```-f``` will keep the logs running.

### Enter a container to debug/test if needed
```
docker exec -it <container_name> bash
```

## 13 - Take the network down
```
./network.sh down
```