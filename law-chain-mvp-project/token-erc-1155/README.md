# ERC-1155 Chaincode

This is a sample ERC-1155 chaincode written in Go.

ERC-20 is the standard for fungible tokens. ERC-721 is the standard for non-fungible tokens. ERC-1155 is the standard for multiple tokens (both fungible and non-fungible). [More information about the ERC-1155 standard can be found here.](https://eips.ethereum.org/EIPS/eip-1155)

## Architecture
This implementation aims for high throughput by minimizing key collisions. The balance of accounts is distributed over multiple keys. The token transfers can be batched using the batched versions of functions (e.g. BatchTransferFrom, BalanceOfBatch). Since ERC-1155 is account-based, the interface of the chaincode is account-based. However, since the balances are distributed over multiple keys, the chaincode has a model similar to a UTXO-based chaincode internally.

In this chaincode, one organization has a minter/burner role just like in the [ERC-20 example in this repository](https://github.com/hyperledger/fabric-samples/tree/main/token-erc-20).


## Functions Implemented
The following required functions of ERC-1155 are implemented:
- safeTransferFrom
- safeBatchTransferFrom
- balanceOf
- balanceOfBatch
- setApprovalForAll
- isApprovedForAll

Note: The "safe" prefix is omitted from "TransferFrom" in the implementation because the prefix is related to some issue about backwards compatibility with older smart contracts in Ethereum.

Note: TransferFrom is used to send a single token type between two users. BatchTransferFrom is used to send multiple tokens between two users. So, BatchTransferFrom is a more general form of TransferFrom. Ethereum defined two functions instead of one because this reduces gas costs. Since there is no gas cost in Fabric, implementing these two functions is unnecessary. Nevertheless, both of them are implemented to to conform the ERC-1155 standard.

## Additional Functions Implemented

The following additional functions are also implemented. The following paragraphs give the reasoning behind adding these functions:
- Optional Metadata URI extension: 
Defined in ERC-1155 but not required. Allows one to set a URI for tokens and get the URI.
  - SetURI
  - URI
- Mint/Burn extension: 
Although Mint / Burn are not required, they are necessary to change the supply of tokens, create new fungible or non-fungible tokens. In a real implementation, they will be implemented unless the supply of the tokens is fixed beforehand. MintBatch / BurnBatch is only implemented to complement the TransferFrom/BatchTransferFrom. Actually, using only MintBatch and BurnBatch would be enough.
  - Mint
  - MintBatch
  - Burn
  - BurnBatch
- Extra/utility functions
  - BatchTransferFromMultiRecipient: This is not defined in the standard. We created this function to solve an issue we encountered. It is only required if a person wants to send tokens to multiple persons in a blockchain block. If a person doesn't use this function and create two transactions in a single block, there will be key conflicts because the chaincode will try to decrement the balance of the sender twice in a block and this causes a key conflict in Fabric [just like explained in here](https://github.com/hyperledger/fabric-samples/tree/main/high-throughput). This problem does not exist in Ethereum because, in Ethereum, the transactions are ordered before they are executed.
  - BroadcastTokenExistence: Explained in ERC-1155 but it is not required. It is only used if a token minter wants to announce the existence of a token without minting it.
  - ClientAccountID: This function is special for Fabric because we do not have wallet addresses in Fabric and users need to know their account ID to transfer tokens.
  - ClientAccountBalance: A shorthand for BalanceOf function.

## Example Usage

### Launch test network 

Open a command terminal and navigate to the test network directory.

```bash
cd fabric-samples/test-network
```

Clean up the existing network if you have any.
```bash
./network.sh down
```

Start test network
```bash
./network.sh up createChannel -ca
```

### Deploy chaincode

Deploy ERC-1155 chaincode.

```bash
./network.sh deployCC -ccn erc1155 -ccp ../token-erc-1155/chaincode-go/ -ccl go
```

### Register identities

In this example, there are two organizations (org). We will register new identities using the CollectingOfficer and EvidenceCustodian Certificate Authorities (CA's), and then use the CA's to generate each identity's certificate and private key.

We need to set the following environment variables to use the Fabric CA client (and subsequent commands). The first command sets Fabric config path. The second command adds Fabric CLI utilities to path.

```bash
export FABRIC_CFG_PATH=${PWD}/../config/
export PATH=${PWD}/../bin:$PATH
```

The terminal we have been using will represent CollectingOfficer. We will use the CollectingOfficer CA to create a new identity. Set the Fabric CA client home to the MSP of the CollectingOfficer CA admin (this identity was generated by the test network script).

```bash
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/collectingofficer.example.com/
```

Register `Person1` identity to CollectingOfficer.
```bash
fabric-ca-client register --caname ca-collectingofficer --id.name person1 --id.secret person1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/collectingofficer/tls-cert.pem"
```

Generate the identity certificates and MSP folder.

```bash
fabric-ca-client enroll -u https://person1:person1pw@localhost:7054 --caname ca-collectingofficer -M "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/users/person1@collectingofficer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/collectingofficer/tls-cert.pem"
```

Copy the Node OU configuration file into the identity MSP folder.

```bash
cp "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/users/person1@collectingofficer.example.com/msp/config.yaml"
```

Open a new terminal to represent EvidenceCustodian and navigate to fabric-samples/test-network. We'll use the EvidenceCustodian CA to create the EvidenceCustodian identities. Set the Fabric CA client home to the MSP of the EvidenceCustodian CA admin.

```bash
cd fabric-samples/test-network
export FABRIC_CFG_PATH=${PWD}/../config/
export PATH=${PWD}/../bin:$PATH
export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/
```

Register `Person2`, `Person3`, `Person4`, `Person5` to EvidenceCustodian.

```bash
fabric-ca-client register --caname ca-evidencecustodian --id.name person2 --id.secret person2pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/evidencecustodian/tls-cert.pem"
fabric-ca-client enroll -u https://person2:person2pw@localhost:8054 --caname ca-evidencecustodian -M "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/users/person2@evidencecustodian.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/evidencecustodian/tls-cert.pem"
cp "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/users/person2@evidencecustodian.example.com/msp/config.yaml"

fabric-ca-client register --caname ca-evidencecustodian --id.name person3 --id.secret person3pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/evidencecustodian/tls-cert.pem"
fabric-ca-client enroll -u https://person3:person3pw@localhost:8054 --caname ca-evidencecustodian -M "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/users/person3@evidencecustodian.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/evidencecustodian/tls-cert.pem"
cp "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/users/person3@evidencecustodian.example.com/msp/config.yaml"

fabric-ca-client register --caname ca-evidencecustodian --id.name person4 --id.secret person4pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/evidencecustodian/tls-cert.pem"
fabric-ca-client enroll -u https://person4:person4pw@localhost:8054 --caname ca-evidencecustodian -M "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/users/person4@evidencecustodian.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/evidencecustodian/tls-cert.pem"
cp "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/users/person4@evidencecustodian.example.com/msp/config.yaml"

fabric-ca-client register --caname ca-evidencecustodian --id.name person5 --id.secret person5pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/evidencecustodian/tls-cert.pem"
fabric-ca-client enroll -u https://person5:person5pw@localhost:8054 --caname ca-evidencecustodian -M "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/users/person5@evidencecustodian.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/evidencecustodian/tls-cert.pem"
cp "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/users/person5@evidencecustodian.example.com/msp/config.yaml"
```

## Initialize the contract
Once we created the identity of the minter we can now initialize the contract.
Note that we need to call the initialize function before being able to use any functions of the contract. Initialize() can be called only once.

Shift back to the CollectingOfficer terminal, we'll set the following environment variables to operate the `peer` CLI as the minter identity from CollectingOfficer.
```bash
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID=CollectingOfficerMSP
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/collectingofficer.example.com/users/person1@collectingofficer.example.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls/ca.crt
export CORE_PEER_ADDRESS=localhost:7051
export TARGET_TLS_OPTIONS=(-o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/tls/ca.crt")```

We can then invoke the smart contract to initialize it:
```bash
peer chaincode invoke "${TARGET_TLS_OPTIONS[@]}" -C mychannel -n erc1155 -c '{"function":"Initialize","Args":["some name", "some symbol"]}'
```

### Get account ID

Now, get client account ID for Person1.
```bash
peer chaincode query -C mychannel -n erc1155 -c '{"function":"ClientAccountID","Args":[]}'
```

```
eDUwOTo6Q049cGVyc29uMSxPVT1jbGllbnQsTz1IeXBlcmxlZGdlcixTVD1Ob3J0aCBDYXJvbGluYSxDPVVTOjpDTj1jYS5vcmcxLmV4YW1wbGUuY29tLE89b3JnMS5leGFtcGxlLmNvbSxMPUR1cmhhbSxTVD1Ob3J0aCBDYXJvbGluYSxDPVVT
```

Client Account ID is a base64-encoded concatenation of the issuer and subject from the client identity's enrolment certificate.
You can decode it with the following command:

```bash
echo "eDUwOTo6Q049cGVyc29uMSxPVT1jbGllbnQsTz1IeXBlcmxlZGdlcixTVD1Ob3J0aCBDYXJvbGluYSxDPVVTOjpDTj1jYS5vcmcxLmV4YW1wbGUuY29tLE89b3JnMS5leGFtcGxlLmNvbSxMPUR1cmhhbSxTVD1Ob3J0aCBDYXJvbGluYSxDPVVT" | base64 --decode
```

```
x509::CN=person1,OU=client,O=Hyperledger,ST=North Carolina,C=US::CN=ca.collectingofficer.example.com,O=collectingofficer.example.com,L=Durham,ST=North Carolina,C=US
```

Set the client account IDs as environment variables on both of the terminals to make the subsequent commands more readable.
```bash
export P1="eDUwOTo6Q049cGVyc29uMSxPVT1jbGllbnQsTz1IeXBlcmxlZGdlcixTVD1Ob3J0aCBDYXJvbGluYSxDPVVTOjpDTj1jYS5vcmcxLmV4YW1wbGUuY29tLE89b3JnMS5leGFtcGxlLmNvbSxMPUR1cmhhbSxTVD1Ob3J0aCBDYXJvbGluYSxDPVVT"
export P2="eDUwOTo6Q049cGVyc29uMixPVT1jbGllbnQsTz1IeXBlcmxlZGdlcixTVD1Ob3J0aCBDYXJvbGluYSxDPVVTOjpDTj1jYS5vcmcyLmV4YW1wbGUuY29tLE89b3JnMi5leGFtcGxlLmNvbSxMPUh1cnNsZXksU1Q9SGFtcHNoaXJlLEM9VUs="
export P3="eDUwOTo6Q049cGVyc29uMyxPVT1jbGllbnQsTz1IeXBlcmxlZGdlcixTVD1Ob3J0aCBDYXJvbGluYSxDPVVTOjpDTj1jYS5vcmcyLmV4YW1wbGUuY29tLE89b3JnMi5leGFtcGxlLmNvbSxMPUh1cnNsZXksU1Q9SGFtcHNoaXJlLEM9VUs="
export P4="eDUwOTo6Q049cGVyc29uNCxPVT1jbGllbnQsTz1IeXBlcmxlZGdlcixTVD1Ob3J0aCBDYXJvbGluYSxDPVVTOjpDTj1jYS5vcmcyLmV4YW1wbGUuY29tLE89b3JnMi5leGFtcGxlLmNvbSxMPUh1cnNsZXksU1Q9SGFtcHNoaXJlLEM9VUs="
export P5="eDUwOTo6Q049cGVyc29uNSxPVT1jbGllbnQsTz1IeXBlcmxlZGdlcixTVD1Ob3J0aCBDYXJvbGluYSxDPVVTOjpDTj1jYS5vcmcyLmV4YW1wbGUuY29tLE89b3JnMi5leGFtcGxlLmNvbSxMPUh1cnNsZXksU1Q9SGFtcHNoaXJlLEM9VUs="
```

### Mint tokens

Mint tokens by calling the MintBatch function in order to create 100 token1s, 200 token2s, 300 token3s, 150 token4s, 100 token5s, 100 token6s as Person P1 from organization 1.

```bash
peer chaincode invoke "${TARGET_TLS_OPTIONS[@]}" -C mychannel -n erc1155 -c "{\"function\":\"MintBatch\",\"Args\":[\"$P1\",\"[1,2,3,4,5,6]\",\"[100,200,300,150,100,100]\"]}" --waitForEvent
```

Query the tokens of Person1.  

```bash
peer chaincode query -C mychannel -n erc1155 -c "{\"function\":\"BalanceOfBatch\",\"Args\":[\"[\\\"$P1\\\",\\\"$P1\\\",\\\"$P1\\\",\\\"$P1\\\",\\\"$P1\\\",\\\"$P1\\\"]\",\"[1,2,3,4,5,6]\"]}"
```

```
[100,200,300,150,100,100]
```

Side note: There may seem too many slashes in the previous command. It double escapes the quotes. One escape is to be able to use quotes in the `-c` argument of the command. The second escape is necessary to pass the account IDs as an array. Quote is needed since the elements of the array are strings. 

### Transfer tokens

#### TransferFrom

Send Person P2 six token3s by calling TransferFrom as Person P1.
```bash
peer chaincode invoke "${TARGET_TLS_OPTIONS[@]}" -C mychannel -n erc1155 -c "{\"function\":\"TransferFrom\",\"Args\":[\"$P1\",\"$P2\",\"3\",\"6\"]}" --waitForEvent
```

Get the new Balance of Person1 for token3.
```bash
peer chaincode query -C mychannel -n erc1155 -c "{\"function\":\"BalanceOf\",\"Args\":[\"$P1\",\"3\"]}"
```

```
294
```

Switch to the EvidenceCustodian terminal and set the following environment variables.
```bash
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID=EvidenceCustodianMSP
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/users/person2@evidencecustodian.example.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/tls/ca.crt
export CORE_PEER_ADDRESS=localhost:9051
export TARGET_TLS_OPTIONS=(-o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/tls/ca.crt")
```

Get the new balance of Person2 for token3.
```bash
peer chaincode query -C mychannel -n erc1155 -c "{\"function\":\"BalanceOf\",\"Args\":[\"$P2\",\"3\"]}"
```

```
6
```

#### BatchTransferFrom

Switch to the CollectingOfficer terminal.

Send Person P2 six token3s, three token4s, and one token2s by calling BatchTransferFrom as Person P1.

```bash
peer chaincode invoke "${TARGET_TLS_OPTIONS[@]}" -C mychannel -n erc1155 -c "{\"function\":\"BatchTransferFrom\",\"Args\":[\"$P1\",\"$P2\",\"[3,4,2]\",\"[6,3,1]\"]}" --waitForEvent
```

#### BatchTransferFromMultiReceipent

Call BatchTransferFromMultiReceipent as Person1 in order to send:
- six token5s to person P3,
- six token3s  to person P4,
- three token4s to person P2,
- two token2s to person P5,
- and three token6s to person P2.

```bash
peer chaincode invoke "${TARGET_TLS_OPTIONS[@]}" -C mychannel -n erc1155 -c "{\"function\":\"BatchTransferFromMultiRecipient\",\"Args\":[\"$P1\",\"[\\\"$P3\\\",\\\"$P4\\\",\\\"$P2\\\",\\\"$P5\\\",\\\"$P2\\\"]\",\"[5,3,4,2,6]\",\"[6,6,3,2,3]\"]}" --waitForEvent
```

### Clean up

When you are finished, you can bring down the test network. This command will bring down the CAs, peers, and ordering node of the network that you created.

```bash
./network.sh down
```

## Acknowledgement

This work has been carried out at Boğaziçi University and has received funding from the European Union’s Horizon 2020 Research and Innovation programme under Grant Agreement No. 856632.
