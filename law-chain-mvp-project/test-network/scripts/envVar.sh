#!/usr/bin/env bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
# test network home var targets to test-network folder
# the reason we use a var here is to accommodate scenarios
# where execution occurs from folders outside of default as $PWD, such as the test-network/addOrg3 folder.
# For setting environment variables, simple relative paths like ".." could lead to unintended references
# due to how they interact with FABRIC_CFG_PATH. It's advised to specify paths more explicitly,
# such as using "../${PWD}", to ensure that Fabric's environment variables are pointing to the correct paths.
TEST_NETWORK_HOME=${TEST_NETWORK_HOME:-${PWD}}
. ${TEST_NETWORK_HOME}/scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${TEST_NETWORK_HOME}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
export PEER0_COLLECTINGOFFICER_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/collectingofficer.example.com/tlsca/tlsca.collectingofficer.example.com-cert.pem
export PEER0_EVIDENCECUSTODIAN_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/evidencecustodian.example.com/tlsca/tlsca.evidencecustodian.example.com-cert.pem
export PEER0_FORENCSICANALYST_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/forensicanalyst.example.com/tlsca/tlsca.forensicanalyst.example.com-cert.pem
export PEER0_PROSECUTOR_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/prosecutor.example.com/tlsca/tlsca.prosecutor.example.com-cert.pem
export PEER0_COURTROOMPERSONNEL_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/courtroompersonnel.example.com/tlsca/tlsca.courtroompersonnel.example.com-cert.pem

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_LOCALMSPID=CollectingOfficerMSP
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_COLLECTINGOFFICER_CA
    export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/collectingofficer.example.com/users/Admin@collectingofficer.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_LOCALMSPID=EvidenceCustodianMSP
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_EVIDENCECUSTODIAN_CA
    export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/evidencecustodian.example.com/users/Admin@evidencecustodian.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_LOCALMSPID=ForensicAnalystMSP
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_FORENCSICANALYST_CA
    export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/forensicanalyst.example.com/users/Admin@forensicanalyst.example.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
  elif [ $USING_ORG -eq 4 ]; then
    export CORE_PEER_LOCALMSPID=ProsecutorMSP
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_PROSECUTOR_CA
    export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/prosecutor.example.com/users/Admin@prosecutor.example.com/msp
    export CORE_PEER_ADDRESS=localhost:13051
  elif [ $USING_ORG -eq 5 ]; then
    export CORE_PEER_LOCALMSPID=CourtroomPersonnelMSP
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_COURTROOMPERSONNEL_CA
    export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/courtroompersonnel.example.com/users/Admin@courtroompersonnel.example.com/msp
    export CORE_PEER_ADDRESS=localhost:15051
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" = "true" ]; then
    env | grep CORE
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=()
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.org$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]
    then
	PEERS="$PEER"
    else
	PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    CA=PEER0_ORG$1_CA
    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
