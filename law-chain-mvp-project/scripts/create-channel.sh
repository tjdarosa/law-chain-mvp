#!/bin/bash

# CONFIGURATION
CHANNEL_NAME="lawchannel"
ORDERER=orderer1.example.com:7050

# Map logical org names to domain names
declare -A ORG_DOMAINS
ORG_DOMAINS=(
  [CollectingOfficerOrg]="collectingofficer.example.com"
  [EvidenceCustodianOrg]="evidencecustodian.example.com"
  [ForensicAnalystOrg]="forensicanalyst.example.com"
  [ProsecutorOrg]="prosecutor.example.com"
)

# Set peer environment
setGlobalsForPeer0() {
  ORG_NAME=$1
  DOMAIN=${ORG_DOMAINS[$ORG_NAME]}

  export CORE_PEER_LOCALMSPID="${ORG_NAME}MSP"
  export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${DOMAIN}/users/Admin@${DOMAIN}/msp
  export CORE_PEER_ADDRESS=peer0.${DOMAIN}:7051
  export CORE_PEER_TLS_ENABLED=false
}

echo "🔧 Creating channel..."
peer channel create \
  -o $ORDERER \
  -c $CHANNEL_NAME \
  -f ./channel-artifacts/${CHANNEL_NAME}.tx \
  --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block

joinChannel() {
  ORG=$1
  echo "🚀 Joining peer0 of $ORG to channel..."
  setGlobalsForPeer0 $ORG
  peer channel join -b ./channel-artifacts/${CHANNEL_NAME}.block
}

updateAnchorPeer() {
  ORG=$1
  echo "📡 Updating anchor peers for $ORG..."
  setGlobalsForPeer0 $ORG
  peer channel update \
    -o $ORDERER \
    -c $CHANNEL_NAME \
    -f ./channel-artifacts/${ORG}Anchors.tx
}

# List your logical org names (matching ORG_DOMAINS keys)
ORGS=("CollectingOfficerOrg" "EvidenceCustodianOrg" "ForensicAnalystOrg" "ProsecutorOrg")

for ORG in "${ORGS[@]}"; do
  joinChannel $ORG
done

for ORG in "${ORGS[@]}"; do
  updateAnchorPeer $ORG
done
