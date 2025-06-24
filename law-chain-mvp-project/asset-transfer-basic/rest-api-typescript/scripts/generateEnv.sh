#!/usr/bin/env bash

#
# SPDX-License-Identifier: Apache-2.0
#

${AS_LOCAL_HOST:=true}

: "${TEST_NETWORK_HOME:=../..}"
: "${CONNECTION_PROFILE_FILE_COLLECTINGOFFICER:=${TEST_NETWORK_HOME}/organizations/peerOrganizations/collectingofficer.example.com/connection-collectingofficer.json}"
: "${CERTIFICATE_FILE_COLLECTINGOFFICER:=${TEST_NETWORK_HOME}/organizations/peerOrganizations/collectingofficer.example.com/users/User1@collectingofficer.example.com/msp/signcerts/User1@collectingofficer.example.com-cert.pem}"
: "${PRIVATE_KEY_FILE_COLLECTINGOFFICER:=${TEST_NETWORK_HOME}/organizations/peerOrganizations/collectingofficer.example.com/users/User1@collectingofficer.example.com/msp/keystore/priv_sk}"

: "${CONNECTION_PROFILE_FILE_EVIDENCECUSTODIAN:=${TEST_NETWORK_HOME}/organizations/peerOrganizations/evidencecustodian.example.com/connection-evidencecustodian.json}"
: "${CERTIFICATE_FILE_EVIDENCECUSTODIAN:=${TEST_NETWORK_HOME}/organizations/peerOrganizations/evidencecustodian.example.com/users/User1@evidencecustodian.example.com/msp/signcerts/User1@evidencecustodian.example.com-cert.pem}"
: "${PRIVATE_KEY_FILE_EVIDENCECUSTODIAN:=${TEST_NETWORK_HOME}/organizations/peerOrganizations/evidencecustodian.example.com/users/User1@evidencecustodian.example.com/msp/keystore/priv_sk}"


cat << ENV_END > .env
# Generated .env file
# See src/config.ts for details of all the available configuration variables
#

LOG_LEVEL=info

PORT=3000

HLF_CERTIFICATE_COLLECTINGOFFICER="$(cat ${CERTIFICATE_FILE_COLLECTINGOFFICER} | sed -e 's/$/\\n/' | tr -d '\r\n')"

HLF_PRIVATE_KEY_COLLECTINGOFFICER="$(cat ${PRIVATE_KEY_FILE_COLLECTINGOFFICER} | sed -e 's/$/\\n/' | tr -d '\r\n')"

HLF_CERTIFICATE_EVIDENCECUSTODIAN="$(cat ${CERTIFICATE_FILE_EVIDENCECUSTODIAN} | sed -e 's/$/\\n/' | tr -d '\r\n')"

HLF_PRIVATE_KEY_EVIDENCECUSTODIAN="$(cat ${PRIVATE_KEY_FILE_EVIDENCECUSTODIAN} | sed -e 's/$/\\n/' | tr -d '\r\n')"

REDIS_PORT=6379

COLLECTINGOFFICER_APIKEY=$(uuidgen)

EVIDENCECUSTODIAN_APIKEY=$(uuidgen)

ENV_END
 
if [ "${AS_LOCAL_HOST}" = "true" ]; then

cat << LOCAL_HOST_END >> .env
AS_LOCAL_HOST=true

HLF_CONNECTION_PROFILE_COLLECTINGOFFICER=$(cat ${CONNECTION_PROFILE_FILE_COLLECTINGOFFICER} | jq -c .)

HLF_CONNECTION_PROFILE_EVIDENCECUSTODIAN=$(cat ${CONNECTION_PROFILE_FILE_EVIDENCECUSTODIAN} | jq -c .)

REDIS_HOST=localhost

LOCAL_HOST_END

elif [ "${AS_LOCAL_HOST}" = "false" ]; then

cat << WITH_HOSTNAME_END >> .env
AS_LOCAL_HOST=false

HLF_CONNECTION_PROFILE_COLLECTINGOFFICER=$(cat ${CONNECTION_PROFILE_FILE_COLLECTINGOFFICER} | jq -c '.peers["peer0.collectingofficer.example.com"].url = "grpcs://peer0.collectingofficer.example.com:7051" | .certificateAuthorities["ca.collectingofficer.example.com"].url = "https://ca.collectingofficer.example.com:7054"')

HLF_CONNECTION_PROFILE_EVIDENCECUSTODIAN=$(cat ${CONNECTION_PROFILE_FILE_EVIDENCECUSTODIAN} | jq -c '.peers["peer0.evidencecustodian.example.com"].url = "grpcs://peer0.evidencecustodian.example.com:9051" | .certificateAuthorities["ca.evidencecustodian.example.com"].url = "https://ca.evidencecustodian.example.com:8054"')

REDIS_HOST=redis

WITH_HOSTNAME_END

fi
