#!/usr/bin/env sh
#
# SPDX-License-Identifier: Apache-2.0
#
set -eu

if [ "$(uname)" = "Linux" ] || [  -d config ]
then
  CCADDR="127.0.0.1"
else
  CCADDR="host.docker.internal"
fi

if [  -d config  ] ; then
  export FABRIC_CFG_PATH="${PWD}"/config
else
  export FABRIC_CFG_PATH="${PWD}"/../config
fi

# look for binaries in local dev environment /build/bin directory and then in local samples /bin directory
export PATH="${PWD}"/../../fabric/build/bin:"${PWD}"/../bin:"$PATH"

export FABRIC_LOGGING_SPEC=debug:cauthdsl,policies,msp,grpc,peer.gossip.mcs,gossip,leveldbhelper=info
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_CERT_FILE="${PWD}"/crypto-config/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE="${PWD}"/crypto-config/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE="${PWD}"/crypto-config/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls/ca.crt
export CORE_PEER_ID=peer0.collectingofficer.example.com
export CORE_PEER_ADDRESS=127.0.0.1:7051
export CORE_PEER_LISTENADDRESS=127.0.0.1:7051
export CORE_PEER_CHAINCODEADDRESS="${CORE_PEER_CHAINCODEADDRESS_HOST_OVERRIDE:-${CCADDR}}":7052
export CORE_PEER_CHAINCODELISTENADDRESS="${CORE_PEER_CHAINCODELISTENADDRESS_HOST_OVERRIDE:-127.0.0.1}":7052
# bootstrap peer is the other peer in the same org
export CORE_PEER_GOSSIP_BOOTSTRAP=127.0.0.1:7053
export CORE_PEER_GOSSIP_EXTERNALENDPOINT=127.0.0.1:7051
export CORE_PEER_LOCALMSPID=CollectingOfficerMSP
export CORE_PEER_MSPCONFIGPATH="${PWD}"/crypto-config/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/msp
export CORE_OPERATIONS_LISTENADDRESS=127.0.0.1:8446
export CORE_PEER_FILESYSTEMPATH="${PWD}"/data/peer0.collectingofficer.example.com
export CORE_LEDGER_SNAPSHOTS_ROOTDIR="${PWD}"/data/peer0.collectingofficer.example.com/snapshots

# uncomment the lines below to utilize couchdb state database, when done with the environment you can stop the couchdb container with "docker rm -f couchdb1"
# export CORE_LEDGER_STATE_STATEDATABASE=CouchDB
# export CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=127.0.0.1:5984
# export CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=admin
# export CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=password
# docker run --publish 5984:5984 --detach -e COUCHDB_USER=admin -e COUCHDB_PASSWORD=password --name couchdb1 couchdb:3.4.2

# start peer
peer node start
