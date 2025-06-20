#!/bin/bash

export CORE_PEER_LOCALMSPID="CustodianMSP"
export CORE_PEER_ADDRESS=peer0.custodian.example.com:7051
export CORE_PEER_MSPCONFIGPATH=organizations/peerOrganizations/custodian.example.com/users/Admin@custodian.example.com/msp
export FABRIC_CFG_PATH=$PWD/config

# Create channel
peer channel create -o orderer.example.com:7050 \
  -c mychannel -f ./channel-artifacts/mychannel.tx \
  --outputBlock ./channel-artifacts/mychannel.block

# Join peer0.org1
peer channel join -b ./channel-artifacts/mychannel.block

# Update anchor peers
peer channel update -o orderer.example.com:7050 -c mychannel \
  -f ./channel-artifacts/CustodianOrgAnchors.tx

# Now set peer0.prosecutor context and repeat
export CORE_PEER_LOCALMSPID="ProsecutorMSP"
export CORE_PEER_ADDRESS=peer0.prosecutor.example.com:9051
export CORE_PEER_MSPCONFIGPATH=crypto-config/peerOrganizations/prosecutor.example.com/users/Admin@prosecutor.example.com/msp

peer channel join -b ./channel-artifacts/mychannel.block
peer channel update -o orderer.example.com:7050 -c mychannel \
  -f ./channel-artifacts/ProsecutorOrgAnchors.tx
