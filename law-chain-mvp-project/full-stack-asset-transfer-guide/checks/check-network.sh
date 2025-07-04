#!/usr/bin/env bash

set -eou pipefail

# All checks run in the workshop root folder
cd "$(dirname "$0")"/..

. checks/utils.sh

EXIT=0

function operator_crds() {
  kubectl get customresourcedefinition.apiextensions.k8s.io/ibpcas.ibp.com
  kubectl get customresourcedefinition.apiextensions.k8s.io/ibpconsoles.ibp.com
  kubectl get customresourcedefinition.apiextensions.k8s.io/ibporderers.ibp.com
  kubectl get customresourcedefinition.apiextensions.k8s.io/ibppeers.ibp.com
}

function fabric_resources() {
  # Did it apply the CRDs?
  kubectl -n ${WORKSHOP_NAMESPACE} get ibpca org0-ca
  kubectl -n ${WORKSHOP_NAMESPACE} get ibpca collectingofficer-ca
  kubectl -n ${WORKSHOP_NAMESPACE} get ibpca evidencecustodian-ca
  kubectl -n ${WORKSHOP_NAMESPACE} get ibppeer collectingofficer-peer1
  kubectl -n ${WORKSHOP_NAMESPACE} get ibppeer collectingofficer-peer2
  kubectl -n ${WORKSHOP_NAMESPACE} get ibppeer evidencecustodian-peer1
  kubectl -n ${WORKSHOP_NAMESPACE} get ibppeer evidencecustodian-peer2
  kubectl -n ${WORKSHOP_NAMESPACE} get ibporderer org0-orderersnode1
  kubectl -n ${WORKSHOP_NAMESPACE} get ibporderer org0-orderersnode2
  kubectl -n ${WORKSHOP_NAMESPACE} get ibporderer org0-orderersnode3
}

function fabric_deployment() {
  kubectl -n ${WORKSHOP_NAMESPACE} get deployment fabric-operator
  kubectl -n ${WORKSHOP_NAMESPACE} get deployment org0-ca
  kubectl -n ${WORKSHOP_NAMESPACE} get deployment org0-orderersnode1
  kubectl -n ${WORKSHOP_NAMESPACE} get deployment org0-orderersnode2
  kubectl -n ${WORKSHOP_NAMESPACE} get deployment org0-orderersnode3
  kubectl -n ${WORKSHOP_NAMESPACE} get deployment collectingofficer-ca
  kubectl -n ${WORKSHOP_NAMESPACE} get deployment collectingofficer-peer1
  kubectl -n ${WORKSHOP_NAMESPACE} get deployment collectingofficer-peer2
  kubectl -n ${WORKSHOP_NAMESPACE} get deployment evidencecustodian-ca
  kubectl -n ${WORKSHOP_NAMESPACE} get deployment evidencecustodian-peer1
  kubectl -n ${WORKSHOP_NAMESPACE} get deployment evidencecustodian-peer2
}

function cas_ready() {
  WORKSHOP_CRYPTO=$WORKSHOP_PATH/infrastructure/sample-network/temp

  # Hit the CAs using the TLS certs, etc.
  curl --fail -s --cacert $WORKSHOP_CRYPTO/cas/org0-ca/tls-cert.pem https://$WORKSHOP_NAMESPACE-org0-ca-ca.$WORKSHOP_INGRESS_DOMAIN/cainfo | jq -c
  curl --fail -s --cacert $WORKSHOP_CRYPTO/cas/collectingofficer-ca/tls-cert.pem https://$WORKSHOP_NAMESPACE-collectingofficer-ca-ca.$WORKSHOP_INGRESS_DOMAIN/cainfo | jq -c
  curl --fail -s --cacert $WORKSHOP_CRYPTO/cas/evidencecustodian-ca/tls-cert.pem https://$WORKSHOP_NAMESPACE-evidencecustodian-ca-ca.$WORKSHOP_INGRESS_DOMAIN/cainfo | jq -c
}

function channel_msp() {
  WORKSHOP_CRYPTO=$WORKSHOP_PATH/infrastructure/sample-network/temp

  find $WORKSHOP_CRYPTO/channel-msp
}

must_declare WORKSHOP_PATH
must_declare FABRIC_CFG_PATH

check operator_crds     "fabric-operator CRDs have been installed"
check fabric_resources  "Network Peers, Orderers, and CAs have been created"
check fabric_deployment "Service deployments are ready"
check cas_ready         "Certificate Authorities are running"
check channel_msp       "Channel has been created"

exit $EXIT

