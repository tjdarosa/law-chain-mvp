#!/usr/bin/env bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This script extends the Hyperledger Fabric test network by adding
# adding a third organization to the network
#

# prepending $PWD/../bin to PATH to ensure we are picking up the correct binaries
# this may be commented out to resolve installed version of tools if desired
export PATH=${PWD}/../../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}/../../config
export VERBOSE=false

. ../scripts/utils.sh

: ${CONTAINER_CLI:="docker"}
if command -v ${CONTAINER_CLI}-compose > /dev/null 2>&1; then
    : ${CONTAINER_CLI_COMPOSE:="${CONTAINER_CLI}-compose"}
else
    : ${CONTAINER_CLI_COMPOSE:="${CONTAINER_CLI} compose"}
fi
infoln "Using ${CONTAINER_CLI} and ${CONTAINER_CLI_COMPOSE}"


# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "  addForensicAnalyst.sh up|down|generate [-c <channel name>] [-t <timeout>] [-d <delay>] [-f <docker-compose-file>] [-s <dbtype>]"
  echo "  addForensicAnalyst.sh -h|--help (print this message)"
  echo "    <mode> - one of 'up', 'down', or 'generate'"
  echo "      - 'up' - add forensicanalyst to the sample network. You need to bring up the test network and create a channel first."
  echo "      - 'down' - bring down the test network and forensicanalyst nodes"
  echo "      - 'generate' - generate required certificates and org definition"
  echo "    -c <channel name> - test network channel name (defaults to \"law-channel\")"
  echo "    -ca <use CA> -  Use a CA to generate the crypto material"
  echo "    -t <timeout> - CLI timeout duration in seconds (defaults to 10)"
  echo "    -d <delay> - delay duration in seconds (defaults to 3)"
  echo "    -s <dbtype> - the database backend to use: goleveldb (default) or couchdb"
  echo "    -verbose - verbose mode"
  echo
  echo "Typically, one would first generate the required certificates and "
  echo "genesis block, then bring up the network. e.g.:"
  echo
  echo "	addForensicAnalyst.sh generate"
  echo "	addForensicAnalyst.sh up"
  echo "	addForensicAnalyst.sh up -c law-channel -s couchdb"
  echo "	addForensicAnalyst.sh down"
  echo
  echo "Taking all defaults:"
  echo "	addForensicAnalyst.sh up"
  echo "	addForensicAnalyst.sh down"
}

# We use the cryptogen tool to generate the cryptographic material
# (x509 certs) for the new org.  After we run the tool, the certs will
# be put in the organizations folder with collectingofficer and evidencecustodian

# Create Organziation crypto material using cryptogen or CAs
function generateForensicAnalyst() {
  # Create crypto material using cryptogen
  if [ "$CRYPTO" == "cryptogen" ]; then
    which cryptogen
    if [ "$?" -ne 0 ]; then
      fatalln "cryptogen tool not found. exiting"
    fi
    infoln "Generating certificates using cryptogen tool"

    infoln "Creating ForensicAnalyst Identities"

    set -x
    cryptogen generate --config=forensicanalyst-crypto.yaml --output="../organizations"
    res=$?
    { set +x; } 2>/dev/null
    if [ $res -ne 0 ]; then
      fatalln "Failed to generate certificates..."
    fi

  fi

  # Create crypto material using Fabric CA
  if [ "$CRYPTO" == "Certificate Authorities" ]; then
    fabric-ca-client version > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
      echo "ERROR! fabric-ca-client binary not found.."
      echo
      echo "Follow the instructions in the Fabric docs to install the Fabric Binaries:"
      echo "https://hyperledger-fabric.readthedocs.io/en/latest/install.html"
      exit 1
    fi

    infoln "Generating certificates using Fabric CA"
    ${CONTAINER_CLI_COMPOSE} -f ${COMPOSE_FILE_CA_BASE} -f $COMPOSE_FILE_CA_FORENCSICANALYST up -d 2>&1

    . fabric-ca/registerEnroll.sh

    sleep 10

    infoln "Creating ForensicAnalyst Identities"
    createForensicAnalyst

  fi

  infoln "Generating CCP files for ForensicAnalyst"
  ./ccp-generate.sh
}

# Generate channel configuration transaction
function generateForensicAnalystDefinition() {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    fatalln "configtxgen tool not found. exiting"
  fi
  infoln "Generating ForensicAnalyst organization definition"
  export FABRIC_CFG_PATH=$PWD
  set -x
  configtxgen -printOrg ForensicAnalystMSP > ../organizations/peerOrganizations/forensicanalyst.example.com/forensicanalyst.json
  res=$?
  { set +x; } 2>/dev/null
  if [ $res -ne 0 ]; then
    fatalln "Failed to generate ForensicAnalyst organization definition..."
  fi
}

function ForensicAnalystUp () {
  # start forensicanalyst nodes

  if [ "$CONTAINER_CLI" == "podman" ]; then
    cp ../podman/core.yaml ../../organizations/peerOrganizations/forensicanalyst.example.com/peers/peer0.forensicanalyst.example.com/
  fi

  if [ "${DATABASE}" == "couchdb" ]; then
    DOCKER_SOCK=${DOCKER_SOCK} ${CONTAINER_CLI_COMPOSE} -f ${COMPOSE_FILE_BASE} -f $COMPOSE_FILE_FORENCSICANALYST -f ${COMPOSE_FILE_COUCH_BASE} -f $COMPOSE_FILE_COUCH_FORENCSICANALYST up -d 2>&1
  else
    DOCKER_SOCK=${DOCKER_SOCK} ${CONTAINER_CLI_COMPOSE} -f ${COMPOSE_FILE_BASE} -f $COMPOSE_FILE_FORENCSICANALYST up -d 2>&1
  fi
  if [ $? -ne 0 ]; then
    fatalln "ERROR !!!! Unable to start ForensicAnalyst network"
  fi
}

# Generate the needed certificates, the genesis block and start the network.
function addForensicAnalyst () {
  # If the test network is not up, abort
  if [ ! -d ../organizations/ordererOrganizations ]; then
    fatalln "ERROR: Please, run ./network.sh up createChannel first."
  fi

  # generate artifacts if they don't exist
  if [ ! -d "../organizations/peerOrganizations/forensicanalyst.example.com" ]; then
    generateForensicAnalyst
    generateForensicAnalystDefinition
  fi

  infoln "Bringing up ForensicAnalyst peer"
  ForensicAnalystUp

  # Create the configuration transaction needed to add
  # ForensicAnalyst to the network
  infoln "Generating and submitting config tx to add ForensicAnalyst"
  export FABRIC_CFG_PATH=${PWD}/../../config
  . ../scripts/forensicanalyst-scripts/updateChannelConfig.sh $CHANNEL_NAME $CLI_DELAY $CLI_TIMEOUT $VERBOSE
  if [ $? -ne 0 ]; then
    fatalln "ERROR !!!! Unable to create config tx"
  fi

  infoln "Joining ForensicAnalyst peers to network"
  . ../scripts/forensicanalyst-scripts/joinChannel.sh $CHANNEL_NAME $CLI_DELAY $CLI_TIMEOUT $VERBOSE
  if [ $? -ne 0 ]; then
    fatalln "ERROR !!!! Unable to join ForensicAnalyst peers to network"
  fi
}

# Tear down running network
function networkDown () {
    cd ..
    ./network.sh down
}

# Using crpto vs CA. default is cryptogen
CRYPTO="cryptogen"
# timeout duration - the duration the CLI should wait for a response from
# another container before giving up
CLI_TIMEOUT=10
#default for delay
CLI_DELAY=3
# channel name defaults to "law-channel"
CHANNEL_NAME="law-channel"
# use this as the docker compose couch file
COMPOSE_FILE_COUCH_BASE=compose/compose-couch-forensicanalyst.yaml
COMPOSE_FILE_COUCH_FORENCSICANALYST=compose/${CONTAINER_CLI}/docker-compose-couch-forensicanalyst.yaml
# use this as the default docker-compose yaml definition
COMPOSE_FILE_BASE=compose/compose-forensicanalyst.yaml
COMPOSE_FILE_FORENCSICANALYST=compose/${CONTAINER_CLI}/docker-compose-forensicanalyst.yaml
# certificate authorities compose file
COMPOSE_FILE_CA_BASE=compose/compose-ca-forensicanalyst.yaml
COMPOSE_FILE_CA_FORENCSICANALYST=compose/${CONTAINER_CLI}/docker-compose-ca-forensicanalyst.yaml
# database
DATABASE="leveldb"

# Get docker sock path from environment variable
SOCK="${DOCKER_HOST:-/var/run/docker.sock}"
DOCKER_SOCK="${SOCK##unix://}"

# Parse commandline args

## Parse mode
if [[ $# -lt 1 ]] ; then
  printHelp
  exit 0
else
  MODE=$1
  shift
fi

# parse flags

while [[ $# -ge 1 ]] ; do
  key="$1"
  case $key in
  -h )
    printHelp
    exit 0
    ;;
  -c )
    CHANNEL_NAME="$2"
    shift
    ;;
  -ca )
    CRYPTO="Certificate Authorities"
    ;;
  -t )
    CLI_TIMEOUT="$2"
    shift
    ;;
  -d )
    CLI_DELAY="$2"
    shift
    ;;
  -s )
    DATABASE="$2"
    shift
    ;;
  -verbose )
    VERBOSE=true
    ;;
  * )
    errorln "Unknown flag: $key"
    printHelp
    exit 1
    ;;
  esac
  shift
done


# Determine whether starting, stopping, restarting or generating for announce
if [ "$MODE" == "up" ]; then
  infoln "Adding forensicanalyst to channel '${CHANNEL_NAME}' with '${CLI_TIMEOUT}' seconds and CLI delay of '${CLI_DELAY}' seconds and using database '${DATABASE}'"
  echo
elif [ "$MODE" == "down" ]; then
  EXPMODE="Stopping network"
elif [ "$MODE" == "generate" ]; then
  EXPMODE="Generating certs and organization definition for ForensicAnalyst"
else
  printHelp
  exit 1
fi

#Create the network using docker compose
if [ "${MODE}" == "up" ]; then
  addForensicAnalyst
elif [ "${MODE}" == "down" ]; then ## Clear the network
  networkDown
elif [ "${MODE}" == "generate" ]; then ## Generate Artifacts
  generateForensicAnalyst
  generateForensicAnalystDefinition
else
  printHelp
  exit 1
fi
