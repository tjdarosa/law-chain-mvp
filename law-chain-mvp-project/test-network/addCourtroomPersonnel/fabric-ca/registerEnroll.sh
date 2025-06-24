#!/usr/bin/env bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

function createCourtroomPersonnel {
	infoln "Enrolling the CA admin"
	mkdir -p ../organizations/peerOrganizations/courtroompersonnel.example.com/

	export FABRIC_CA_CLIENT_HOME=${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:11054 --caname ca-courtroompersonnel --tls.certfiles "${PWD}/fabric-ca/courtroompersonnel/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-courtroompersonnel.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-courtroompersonnel.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-courtroompersonnel.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-11054-ca-courtroompersonnel.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/msp/config.yaml"

	infoln "Registering peer0"
  set -x
	fabric-ca-client register --caname ca-courtroompersonnel --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/fabric-ca/courtroompersonnel/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-courtroompersonnel --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/fabric-ca/courtroompersonnel/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-courtroompersonnel --id.name courtroompersonneladmin --id.secret courtroompersonneladminpw --id.type admin --tls.certfiles "${PWD}/fabric-ca/courtroompersonnel/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
	fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-courtroompersonnel -M "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/peers/peer0.courtroompersonnel.example.com/msp" --tls.certfiles "${PWD}/fabric-ca/courtroompersonnel/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/msp/config.yaml" "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/peers/peer0.courtroompersonnel.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:11054 --caname ca-courtroompersonnel -M "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/peers/peer0.courtroompersonnel.example.com/tls" --enrollment.profile tls --csr.hosts peer0.courtroompersonnel.example.com --csr.hosts localhost --tls.certfiles "${PWD}/fabric-ca/courtroompersonnel/tls-cert.pem"
  { set +x; } 2>/dev/null


  cp "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/peers/peer0.courtroompersonnel.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/peers/peer0.courtroompersonnel.example.com/tls/ca.crt"
  cp "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/peers/peer0.courtroompersonnel.example.com/tls/signcerts/"* "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/peers/peer0.courtroompersonnel.example.com/tls/server.crt"
  cp "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/peers/peer0.courtroompersonnel.example.com/tls/keystore/"* "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/peers/peer0.courtroompersonnel.example.com/tls/server.key"

  mkdir "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/msp/tlscacerts"
  cp "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/peers/peer0.courtroompersonnel.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/msp/tlscacerts/ca.crt"

  mkdir "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/tlsca"
  cp "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/peers/peer0.courtroompersonnel.example.com/tls/tlscacerts/"* "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/tlsca/tlsca.courtroompersonnel.example.com-cert.pem"

  mkdir "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/ca"
  cp "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/peers/peer0.courtroompersonnel.example.com/msp/cacerts/"* "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/ca/ca.courtroompersonnel.example.com-cert.pem"

  infoln "Generating the user msp"
  set -x
	fabric-ca-client enroll -u https://user1:user1pw@localhost:11054 --caname ca-courtroompersonnel -M "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/users/User1@courtroompersonnel.example.com/msp" --tls.certfiles "${PWD}/fabric-ca/courtroompersonnel/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/msp/config.yaml" "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/users/User1@courtroompersonnel.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
	fabric-ca-client enroll -u https://courtroompersonneladmin:courtroompersonneladminpw@localhost:11054 --caname ca-courtroompersonnel -M "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/users/Admin@courtroompersonnel.example.com/msp" --tls.certfiles "${PWD}/fabric-ca/courtroompersonnel/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/msp/config.yaml" "${PWD}/../organizations/peerOrganizations/courtroompersonnel.example.com/users/Admin@courtroompersonnel.example.com/msp/config.yaml"
}
