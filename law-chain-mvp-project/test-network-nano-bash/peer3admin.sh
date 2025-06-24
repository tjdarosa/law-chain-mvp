#!/usr/bin/env sh
#
# SPDX-License-Identifier: Apache-2.0
#

# look for binaries in local dev environment /build/bin directory and then in local samples /bin directory
export PATH="${PWD}"/../../fabric/build/bin:"${PWD}"/../bin:"$PATH"
export FABRIC_CFG_PATH="${PWD}"/../config

export FABRIC_LOGGING_SPEC=INFO
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_ROOTCERT_FILE="${PWD}"/crypto-config/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/tls/ca.crt
export CORE_PEER_ADDRESS=127.0.0.1:7055
export CORE_PEER_LOCALMSPID=EvidenceCustodianMSP
export CORE_PEER_MSPCONFIGPATH="${PWD}"/crypto-config/peerOrganizations/evidencecustodian.example.com/users/Admin@evidencecustodian.example.com/msp
