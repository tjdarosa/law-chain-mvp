#!/usr/bin/env bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

function createProsecutor {
	infoln "Enrolling the CA admin"
	mkdir -p ../organizations/peerOrganizations/prosecutor.example.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/../organizations/peerOrganizations/prosecutor.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca-prosecutor --tls.certfiles "${PWD}/fabric-ca/prosecutor/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-prosecutor.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-prosecutor.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-prosecutor.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-prosecutor.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/msp/config.yaml"

	infoln "Registering peer0"
  set -x
	fabric-ca-client register --caname ca-prosecutor --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/fabric-ca/prosecutor/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-prosecutor --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/fabric-ca/prosecutor/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-prosecutor --id.name prosecutoradmin --id.secret prosecutoradminpw --id.type admin --tls.certfiles "${PWD}/fabric-ca/prosecutor/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-prosecutor -M "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/msp" --tls.certfiles "${PWD}/fabric-ca/prosecutor/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/msp/config.yaml" "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-prosecutor -M "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/tls" --enrollment.profile tls --csr.hosts peer0.prosecutor.example.com --csr.hosts localhost --tls.certfiles "${PWD}/fabric-ca/prosecutor/tls-cert.pem"
  { set +x; } 2>/dev/null


  cp "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/tls/ca.crt"
  cp "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/tls/signcerts/"* "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/tls/server.crt"
  cp "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/tls/keystore/"* "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/tls/server.key"

  mkdir "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/msp/tlscacerts"
  cp "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/msp/tlscacerts/ca.crt"

  mkdir "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/tlsca"
  cp "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/tlsca/tlsca.prosecutor.example.com-cert.pem"

  mkdir "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/ca"
  cp "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/peers/peer0.prosecutor.example.com/msp/cacerts/"* "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/ca/ca.prosecutor.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:11054 --caname ca-prosecutor -M "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/users/User1@prosecutor.example.com/msp" --tls.certfiles "${PWD}/fabric-ca/prosecutor/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/msp/config.yaml" "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/users/User1@prosecutor.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
	fabric-ca-client enroll -u https://prosecutoradmin:prosecutoradminpw@localhost:11054 --caname ca-prosecutor -M "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/users/Admin@prosecutor.example.com/msp" --tls.certfiles "${PWD}/fabric-ca/prosecutor/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/msp/config.yaml" "${PWD}/../organizations/peerOrganizations/prosecutor.example.com/users/Admin@prosecutor.example.com/msp/config.yaml"
}
