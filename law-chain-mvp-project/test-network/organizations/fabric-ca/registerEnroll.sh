#!/usr/bin/env bash

function createCollectingOfficer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/collectingofficer.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/collectingofficer.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-collectingofficer --tls.certfiles "${PWD}/organizations/fabric-ca/collectingofficer/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-collectingofficer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-collectingofficer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-collectingofficer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-collectingofficer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy collectingofficer's CA cert to collectingofficer's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/collectingofficer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/msp/tlscacerts/ca.crt"

  # Copy collectingofficer's CA cert to collectingofficer's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/collectingofficer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/tlsca/tlsca.collectingofficer.example.com-cert.pem"

  # Copy collectingofficer's CA cert to collectingofficer's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/collectingofficer/ca-cert.pem" "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/ca/ca.collectingofficer.example.com-cert.pem"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-collectingofficer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/collectingofficer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-collectingofficer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/collectingofficer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-collectingofficer --id.name collectingofficeradmin --id.secret collectingofficeradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/collectingofficer/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-collectingofficer -M "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/collectingofficer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-collectingofficer -M "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls" --enrollment.profile tls --csr.hosts peer0.collectingofficer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/collectingofficer/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/peers/peer0.collectingofficer.example.com/tls/server.key"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-collectingofficer -M "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/users/User1@collectingofficer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/collectingofficer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/users/User1@collectingofficer.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://collectingofficeradmin:collectingofficeradminpw@localhost:7054 --caname ca-collectingofficer -M "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/users/Admin@collectingofficer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/collectingofficer/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/collectingofficer.example.com/users/Admin@collectingofficer.example.com/msp/config.yaml"
}

function createEvidenceCustodian() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/evidencecustodian.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-evidencecustodian --tls.certfiles "${PWD}/organizations/fabric-ca/evidencecustodian/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-evidencecustodian.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-evidencecustodian.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-evidencecustodian.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-evidencecustodian.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy evidencecustodian's CA cert to evidencecustodian's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/evidencecustodian/ca-cert.pem" "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/msp/tlscacerts/ca.crt"

  # Copy evidencecustodian's CA cert to evidencecustodian's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/evidencecustodian/ca-cert.pem" "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/tlsca/tlsca.evidencecustodian.example.com-cert.pem"

  # Copy evidencecustodian's CA cert to evidencecustodian's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/evidencecustodian/ca-cert.pem" "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/ca/ca.evidencecustodian.example.com-cert.pem"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-evidencecustodian --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/evidencecustodian/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-evidencecustodian --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/evidencecustodian/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-evidencecustodian --id.name evidencecustodianadmin --id.secret evidencecustodianadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/evidencecustodian/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-evidencecustodian -M "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/evidencecustodian/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-evidencecustodian -M "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/tls" --enrollment.profile tls --csr.hosts peer0.evidencecustodian.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/evidencecustodian/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/peers/peer0.evidencecustodian.example.com/tls/server.key"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-evidencecustodian -M "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/users/User1@evidencecustodian.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/evidencecustodian/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/users/User1@evidencecustodian.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://evidencecustodianadmin:evidencecustodianadminpw@localhost:8054 --caname ca-evidencecustodian -M "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/users/Admin@evidencecustodian.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/evidencecustodian/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/evidencecustodian.example.com/users/Admin@evidencecustodian.example.com/msp/config.yaml"
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy orderer org's CA cert to orderer org's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  # Copy orderer org's CA cert to orderer org's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"

# Loop through each orderer (orderer, orderer2, orderer3, orderer4) to register and generate artifacts
  for ORDERER in orderer orderer2 orderer3 orderer4; do
    infoln "Registering ${ORDERER}"
    set -x
    fabric-ca-client register --caname ca-orderer --id.name ${ORDERER} --id.secret ${ORDERER}pw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
    { set +x; } 2>/dev/null

    infoln "Generating the ${ORDERER} MSP"
    set -x
    fabric-ca-client enroll -u https://${ORDERER}:${ORDERER}pw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
    { set +x; } 2>/dev/null

    cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/msp/config.yaml"

    # Workaround: Rename the signcert file to ensure consistency with Cryptogen generated artifacts
    mv "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/msp/signcerts/cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/msp/signcerts/${ORDERER}.example.com-cert.pem"

    infoln "Generating the ${ORDERER} TLS certificates, use --csr.hosts to specify Subject Alternative Names"
    set -x
    fabric-ca-client enroll -u https://${ORDERER}:${ORDERER}pw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/tls" --enrollment.profile tls --csr.hosts ${ORDERER}.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
    { set +x; } 2>/dev/null

    # Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
    cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/tls/ca.crt"
    cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/tls/server.crt"
    cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/tls/server.key"

    # Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
    mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/msp/tlscacerts"
    cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/${ORDERER}.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
  done

  # Register and generate artifacts for the orderer admin
  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml"
}
