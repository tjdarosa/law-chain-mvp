#!/usr/bin/env bash

source scripts/utils.sh

CHANNEL_NAME=${1:-"law-channel"}
CC_NAME=${2}
CC_SRC_PATH=${3}
CC_SRC_LANGUAGE=${4}
CC_VERSION=${5:-"1.0"}
CC_SEQUENCE=${6:-"1"}
CC_INIT_FCN=${7:-"NA"}
CC_END_POLICY=${8:-"NA"}
CC_COLL_CONFIG=${9:-"NA"}
DELAY=${10:-"3"}
MAX_RETRY=${11:-"5"}
VERBOSE=${12:-"false"}

println "executing with the following"
println "- CHANNEL_NAME: ${C_GREEN}${CHANNEL_NAME}${C_RESET}"
println "- CC_NAME: ${C_GREEN}${CC_NAME}${C_RESET}"
println "- CC_SRC_PATH: ${C_GREEN}${CC_SRC_PATH}${C_RESET}"
println "- CC_SRC_LANGUAGE: ${C_GREEN}${CC_SRC_LANGUAGE}${C_RESET}"
println "- CC_VERSION: ${C_GREEN}${CC_VERSION}${C_RESET}"
println "- CC_SEQUENCE: ${C_GREEN}${CC_SEQUENCE}${C_RESET}"
println "- CC_END_POLICY: ${C_GREEN}${CC_END_POLICY}${C_RESET}"
println "- CC_COLL_CONFIG: ${C_GREEN}${CC_COLL_CONFIG}${C_RESET}"
println "- CC_INIT_FCN: ${C_GREEN}${CC_INIT_FCN}${C_RESET}"
println "- DELAY: ${C_GREEN}${DELAY}${C_RESET}"
println "- MAX_RETRY: ${C_GREEN}${MAX_RETRY}${C_RESET}"
println "- VERBOSE: ${C_GREEN}${VERBOSE}${C_RESET}"

INIT_REQUIRED="--init-required"
# check if the init fcn should be called
if [ "$CC_INIT_FCN" = "NA" ]; then
  INIT_REQUIRED=""
fi

if [ "$CC_END_POLICY" = "NA" ]; then
  CC_END_POLICY=""
else
  CC_END_POLICY="--signature-policy $CC_END_POLICY"
fi

if [ "$CC_COLL_CONFIG" = "NA" ]; then
  CC_COLL_CONFIG=""
else
  CC_COLL_CONFIG="--collections-config $CC_COLL_CONFIG"
fi

FABRIC_CFG_PATH=$PWD/../config/

# import utils
. scripts/envVar.sh
. scripts/ccutils.sh

function checkPrereqs() {
  jq --version > /dev/null 2>&1

  if [[ $? -ne 0 ]]; then
    errorln "jq command not found..."
    errorln
    errorln "Follow the instructions in the Fabric docs to install the prereqs"
    errorln "https://hyperledger-fabric.readthedocs.io/en/latest/prereqs.html"
    exit 1
  fi
}

#check for prerequisites
checkPrereqs

## package the chaincode
./scripts/packageCC.sh $CC_NAME $CC_SRC_PATH $CC_SRC_LANGUAGE $CC_VERSION 

PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid ${CC_NAME}.tar.gz)

## Install chaincode on peer0.collectingofficer and peer0.evidencecustodian
infoln "Installing chaincode on peer0.collectingofficer..."
installChaincode 1
infoln "Install chaincode on peer0.evidencecustodian..."
installChaincode 2
infoln "Install chaincode on peer0.forensicanalyst..."
installChaincode 3
infoln "Install chaincode on peer0.prosecutor..."
installChaincode 4
infoln "Install chaincode on peer0.courtroompersonnel..."
installChaincode 5

resolveSequence

## query whether the chaincode is installed
queryInstalled 1

## approve the definition for collectingofficer
approveForMyOrg 1

## check whether the chaincode definition is ready to be committed
## expect collectingofficer to have approved and evidencecustodian not to
checkCommitReadiness 1 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": false" #"\"ForensicAnalyst\": false" "\"Prosecutor\": false" "\"CourtroomPersonnel\": false"
checkCommitReadiness 2 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": false" #"\"ForensicAnalyst\": false" "\"Prosecutor\": false" "\"CourtroomPersonnel\": false"
checkCommitReadiness 3 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": false" #"\"ForensicAnalyst\": false" "\"Prosecutor\": false" "\"CourtroomPersonnel\": false"
checkCommitReadiness 4 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": false" #"\"ForensicAnalyst\": false" "\"Prosecutor\": false" "\"CourtroomPersonnel\": false"
checkCommitReadiness 5 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": false" #"\"ForensicAnalyst\": false" "\"Prosecutor\": false" "\"CourtroomPersonnel\": false"

## now approve also for evidencecustodian
approveForMyOrg 2

## check whether the chaincode definition is ready to be committed
## expect them both to have approved
checkCommitReadiness 1 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": false" "\"Prosecutor\": false" "\"CourtroomPersonnel\": false" 
checkCommitReadiness 2 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": false" "\"Prosecutor\": false" "\"CourtroomPersonnel\": false" 
checkCommitReadiness 3 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": false" "\"Prosecutor\": false" "\"CourtroomPersonnel\": false" 
checkCommitReadiness 4 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": false" "\"Prosecutor\": false" "\"CourtroomPersonnel\": false" 
checkCommitReadiness 5 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": false" "\"Prosecutor\": false" "\"CourtroomPersonnel\": false"

## approve the definition for forensicanalyst
approveForMyOrg 3

## check whether the chaincode definition is ready to be committed
## expect collectingofficer to have approved and evidencecustodian not to
checkCommitReadiness 1 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": true" "\"Prosecutor\": false" "\"CourtroomPersonnel\": false"
checkCommitReadiness 2 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": true" "\"Prosecutor\": false" "\"CourtroomPersonnel\": false"
checkCommitReadiness 3 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": true" "\"Prosecutor\": false" "\"CourtroomPersonnel\": false"
checkCommitReadiness 4 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": true" "\"Prosecutor\": false" "\"CourtroomPersonnel\": false"
checkCommitReadiness 5 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": true" "\"Prosecutor\": false" "\"CourtroomPersonnel\": false"

## approve the definition for prosecutor
approveForMyOrg 4

## check whether the chaincode definition is ready to be committed
## expect collectingofficer to have approved and evidencecustodian not to
checkCommitReadiness 1 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": true" "\"Prosecutor\": true" "\"CourtroomPersonnel\": false"
checkCommitReadiness 2 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": true" "\"Prosecutor\": true" "\"CourtroomPersonnel\": false"
checkCommitReadiness 3 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": true" "\"Prosecutor\": true" "\"CourtroomPersonnel\": false"
checkCommitReadiness 4 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": true" "\"Prosecutor\": true" "\"CourtroomPersonnel\": false"
checkCommitReadiness 5 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": true" "\"Prosecutor\": true" "\"CourtroomPersonnel\": false"

## approve the definition for courtroompersonnel
approveForMyOrg 5

## check whether the chaincode definition is ready to be committed
## expect collectingofficer to have approved and evidencecustodian not to
checkCommitReadiness 1 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": true" "\"Prosecutor\": true" "\"CourtroomPersonnel\": true"
checkCommitReadiness 2 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": true" "\"Prosecutor\": true" "\"CourtroomPersonnel\": true"
checkCommitReadiness 3 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": true" "\"Prosecutor\": true" "\"CourtroomPersonnel\": true"
checkCommitReadiness 4 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": true" "\"Prosecutor\": true" "\"CourtroomPersonnel\": true"
checkCommitReadiness 5 "\"CollectingOfficerMSP\": true" "\"EvidenceCustodianMSP\": true" #"\"ForensicAnalyst\": true" "\"Prosecutor\": true" "\"CourtroomPersonnel\": true"

## now that we know for sure both orgs have approved, commit the definition
commitChaincodeDefinition 1 2 3 4 5

## query on both orgs to see that the definition committed successfully
queryCommitted 1
queryCommitted 2
queryCommitted 3
queryCommitted 4
queryCommitted 5

## Invoke the chaincode - this does require that the chaincode have the 'initLedger'
## method defined
if [ "$CC_INIT_FCN" = "NA" ]; then
  infoln "Chaincode initialization is not required"
else
  chaincodeInvokeInit 1 2 3 4 5
fi

exit 0
