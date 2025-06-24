#!/usr/bin/env bash
#
# SPDX-License-Identifier: Apache-2.0




# default to using CollectingOfficer
ORG=${1:-CollectingOfficer}

# Exit on first error, print all commands.
set -e
set -o pipefail

# Where am I?
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

ORDERER_CA=${DIR}/test-network/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
PEER0_COLLECTINGOFFICER_CA=${DIR}/test-network/organizations/peerOrganizations/collectingofficer.example.com/tlsca/tlsca.collectingofficer.example.com-cert.pem
PEER0_EVIDENCECUSTODIAN_CA=${DIR}/test-network/organizations/peerOrganizations/evidencecustodian.example.com/tlsca/tlsca.evidencecustodian.example.com-cert.pem
PEER0_FORENCSICANALYST_CA=${DIR}/test-network/organizations/peerOrganizations/forensicanalyst.example.com/tlsca/tlsca.forensicanalyst.example.com-cert.pem
PEER0_PROSECUTOR_CA=${DIR}/test-network/organizations/peerOrganizations/prosecutor.example.com/tlsca/tlsca.prosecutor.example.com-cert.pem
PEER0_COURTROOMPERSONNEL_CA=${DIR}/test-network/organizations/peerOrganizations/courtroompersonnel.example.com/tlsca/tlsca.courtroompersonnel.example.com-cert.pem


if [[ ${ORG,,} == "collectingofficer" || ${ORG,,} == "digibank" ]]; then

   CORE_PEER_LOCALMSPID=CollectingOfficerMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/collectingofficer.example.com/users/Admin@collectingofficer.example.com/msp
   CORE_PEER_ADDRESS=localhost:7051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/collectingofficer.example.com/tlsca/tlsca.collectingofficer.example.com-cert.pem

elif [[ ${ORG,,} == "evidencecustodian" || ${ORG,,} == "magnetocorp" ]]; then

   CORE_PEER_LOCALMSPID=EvidenceCustodianMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/evidencecustodian.example.com/users/Admin@evidencecustodian.example.com/msp
   CORE_PEER_ADDRESS=localhost:9051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/evidencecustodian.example.com/tlsca/tlsca.evidencecustodian.example.com-cert.pem

else
   echo "Unknown \"$ORG\", please choose CollectingOfficer/Digibank or EvidenceCustodian/Magnetocorp"
   echo "For example to get the environment variables to set upa EvidenceCustodian shell environment run:  ./setOrgEnv.sh EvidenceCustodian"
   echo
   echo "This can be automated to set them as well with:"
   echo
   echo 'export $(./setOrgEnv.sh EvidenceCustodian | xargs)'
   exit 1
fi

# output the variables that need to be set
echo "CORE_PEER_TLS_ENABLED=true"
echo "ORDERER_CA=${ORDERER_CA}"
echo "PEER0_COLLECTINGOFFICER_CA=${PEER0_COLLECTINGOFFICER_CA}"
echo "PEER0_EVIDENCECUSTODIAN_CA=${PEER0_EVIDENCECUSTODIAN_CA}"
echo "PEER0_FORENCSICANALYST_CA=${PEER0_FORENCSICANALYST_CA}"
echo "PEER0_PROSECUTOR_CA=${PEER0_PROSECUTOR_CA}"
echo "PEER0_COURTROOMPERSONNEL_CA=${PEER0_COURTROOMPERSONNEL_CA}"

echo "CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH}"
echo "CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS}"
echo "CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE}"

echo "CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID}"
