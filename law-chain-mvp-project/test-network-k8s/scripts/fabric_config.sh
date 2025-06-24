#!/usr/bin/env bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

function init_namespace() {
  local namespaces=$(echo "$ORG0_NS $COLLECTINGOFFICER_NS $EVIDENCECUSTODIAN_NS" | xargs -n1 | sort -u)
  for ns in $namespaces; do
    push_fn "Creating namespace \"$ns\""
    kubectl create namespace $ns || true
    pop_fn
  done
}

function delete_namespace() {
  local namespaces=$(echo "$ORG0_NS $COLLECTINGOFFICER_NS $EVIDENCECUSTODIAN_NS" | xargs -n1 | sort -u)
  for ns in $namespaces; do
    push_fn "Deleting namespace \"$ns\""
    kubectl delete namespace $ns || true
    pop_fn
  done
}

function init_storage_volumes() {
  push_fn "Provisioning volume storage"

  # Both KIND and k3s use the Rancher local-path provider.  In KIND, this is installed
  # as the 'standard' storage class, and in Rancher as the 'local-path' storage class.
  if [ "${CLUSTER_RUNTIME}" == "kind" ]; then
    export STORAGE_CLASS="standard"

  elif [ "${CLUSTER_RUNTIME}" == "k3s" ]; then
    export STORAGE_CLASS="local-path"

  else
    echo "Unknown CLUSTER_RUNTIME ${CLUSTER_RUNTIME}"
    exit 1
  fi

  cat kube/pvc-fabric-org0.yaml | envsubst | kubectl -n $ORG0_NS create -f - || true
  cat kube/pvc-fabric-collectingofficer.yaml | envsubst | kubectl -n $COLLECTINGOFFICER_NS create -f - || true
  cat kube/pvc-fabric-evidencecustodian.yaml | envsubst | kubectl -n $EVIDENCECUSTODIAN_NS create -f - || true

  pop_fn
}

function load_org_config() {
  push_fn "Creating fabric config maps"

  kubectl -n $ORG0_NS delete configmap org0-config || true
  kubectl -n $COLLECTINGOFFICER_NS delete configmap collectingofficer-config || true
  kubectl -n $EVIDENCECUSTODIAN_NS delete configmap evidencecustodian-config || true

  kubectl -n $ORG0_NS create configmap org0-config --from-file=config/org0
  kubectl -n $COLLECTINGOFFICER_NS create configmap collectingofficer-config --from-file=config/collectingofficer
  kubectl -n $EVIDENCECUSTODIAN_NS create configmap evidencecustodian-config --from-file=config/evidencecustodian

  pop_fn
}

function apply_k8s_builder_roles() {
  push_fn "Applying k8s chaincode builder roles"

  apply_template kube/fabric-builder-role.yaml $COLLECTINGOFFICER_NS
  apply_template kube/fabric-builder-rolebinding.yaml $COLLECTINGOFFICER_NS

  pop_fn
}

function apply_k8s_builders() {
  push_fn "Installing k8s chaincode builders"

  apply_template kube/collectingofficer/collectingofficer-install-k8s-builder.yaml $COLLECTINGOFFICER_NS
  apply_template kube/evidencecustodian/evidencecustodian-install-k8s-builder.yaml $EVIDENCECUSTODIAN_NS

  kubectl -n $COLLECTINGOFFICER_NS wait --for=condition=complete --timeout=60s job/collectingofficer-install-k8s-builder
  kubectl -n $EVIDENCECUSTODIAN_NS wait --for=condition=complete --timeout=60s job/evidencecustodian-install-k8s-builder

  pop_fn
}