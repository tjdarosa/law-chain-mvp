#!/usr/bin/env bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This magical awk script led to 30 hours of debugging a "TLS handshake error"
# moral: do not edit / alter the number of '\' in the following transform:
function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
  local ORG=$1
  local PP=$(one_line_pem $2)
  local CP=$(one_line_pem $3)
  local NS=$4
  sed -e "s/\${ORG}/$ORG/" \
      -e "s#\${PEERPEM}#$PP#" \
      -e "s#\${CAPEM}#$CP#" \
      -e "s#\${NS}#$NS#" \
      scripts/ccp-template.json
}

function construct_rest_sample_configmap() {
  local ns=$COLLECTINGOFFICER_NS
  push_fn "Constructing fabric-rest-sample connection profiles"

  ENROLLMENT_DIR=${TEMP_DIR}/enrollments
  CHANNEL_MSP_DIR=${TEMP_DIR}/channel-msp
  CONFIG_DIR=${TEMP_DIR}/fabric-rest-sample-config 

  mkdir -p $CONFIG_DIR

  local peer_pem=$CHANNEL_MSP_DIR/peerOrganizations/collectingofficer/msp/tlscacerts/tlsca-signcert.pem
  local ca_pem=$CHANNEL_MSP_DIR/peerOrganizations/collectingofficer/msp/cacerts/ca-signcert.pem
  echo "$(json_ccp 1 $peer_pem $ca_pem $COLLECTINGOFFICER_NS)" > build/fabric-rest-sample-config/HLF_CONNECTION_PROFILE_COLLECTINGOFFICER

  peer_pem=$CHANNEL_MSP_DIR/peerOrganizations/evidencecustodian/msp/tlscacerts/tlsca-signcert.pem
  ca_pem=$CHANNEL_MSP_DIR/peerOrganizations/evidencecustodian/msp/cacerts/ca-signcert.pem
  echo "$(json_ccp 2 $peer_pem $ca_pem $EVIDENCECUSTODIAN_NS)" > build/fabric-rest-sample-config/HLF_CONNECTION_PROFILE_EVIDENCECUSTODIAN

  cp $ENROLLMENT_DIR/collectingofficer/users/collectingofficeradmin/msp/signcerts/cert.pem $CONFIG_DIR/HLF_CERTIFICATE_COLLECTINGOFFICER
  cp $ENROLLMENT_DIR/evidencecustodian/users/evidencecustodianadmin/msp/signcerts/cert.pem $CONFIG_DIR/HLF_CERTIFICATE_EVIDENCECUSTODIAN

  cp $ENROLLMENT_DIR/collectingofficer/users/collectingofficeradmin/msp/keystore/key.pem $CONFIG_DIR/HLF_PRIVATE_KEY_COLLECTINGOFFICER
  cp $ENROLLMENT_DIR/evidencecustodian/users/evidencecustodianadmin/msp/keystore/key.pem $CONFIG_DIR/HLF_PRIVATE_KEY_EVIDENCECUSTODIAN

  kubectl -n $ns delete configmap fabric-rest-sample-config || true
  kubectl -n $ns create configmap fabric-rest-sample-config --from-file=$CONFIG_DIR

  pop_fn
}

function rollout_rest_sample() {
  local ns=$COLLECTINGOFFICER_NS
  push_fn "Starting fabric-rest-sample"

  kubectl -n $ns apply -f kube/fabric-rest-sample.yaml
  kubectl -n $ns rollout status deploy/fabric-rest-sample

  pop_fn
}

function launch_rest_sample() {
  local ns=$COLLECTINGOFFICER_NS
  construct_rest_sample_configmap

  apply_template kube/fabric-rest-sample.yaml $ns

  kubectl -n $ns rollout status deploy/fabric-rest-sample

  log ""
  log "The fabric-rest-sample has started."
  log "See https://github.com/hyperledger/fabric-samples/tree/main/asset-transfer-basic/rest-api-typescript for additional usage details."
  log "To access the endpoint:"
  log ""
  log "export SAMPLE_APIKEY=97834158-3224-4CE7-95F9-A148C886653E"
  log 'curl -s --header "X-Api-Key: ${SAMPLE_APIKEY}" http://fabric-rest-sample.'${DOMAIN}'/api/assets'
  log ""
}