#!/usr/bin/env sh
#
# SPDX-License-Identifier: Apache-2.0
#
export PATH="${PWD}"/../../fabric/build/bin:"${PWD}"/../bin:"$PATH"

export crypto_dir=$PWD/crypto-config

export orderer_org_dir=${crypto_dir}/ordererOrganizations/example.com
export collectingofficer_dir=${crypto_dir}/peerOrganizations/collectingofficer.example.com
export evidencecustodian_dir=${crypto_dir}/peerOrganizations/evidencecustodian.example.com

export orderer1_dir=${orderer_org_dir}/orderers/orderer.example.com
export orderer2_dir=${orderer_org_dir}/orderers/orderer2.example.com
export orderer3_dir=${orderer_org_dir}/orderers/orderer3.example.com
export orderer4_dir=${orderer_org_dir}/orderers/orderer4.example.com
export orderer5_dir=${orderer_org_dir}/orderers/orderer5.example.com

export peer0collectingofficer_dir=${collectingofficer_dir}/peers/peer0.collectingofficer.example.com
export peer1collectingofficer_dir=${collectingofficer_dir}/peers/peer1.collectingofficer.example.com

export peer0evidencecustodian_dir=${evidencecustodian_dir}/peers/peer0.evidencecustodian.example.com
export peer1evidencecustodian_dir=${evidencecustodian_dir}/peers/peer1.evidencecustodian.example.com

export orderer_org_tls=${PWD}/data_ca/ordererca/ca/ca-cert.pem
export collectingofficer_tls=${PWD}/data_ca/collectingofficerca/ca/ca-cert.pem
export evidencecustodian_tls=${PWD}/data_ca/evidencecustodianca/ca/ca-cert.pem

# import utilies
. ca/ca_utils.sh

######################################################################################
#  Create admin certificates for the CAs
######################################################################################

# Enroll CA Admin for ordererca
createEnrollment "5052" "admin" "adminpw" "" "${orderer_org_dir}/ca" "${orderer_org_tls}"

# Enroll CA Admin for collectingofficerca
createEnrollment "5053" "admin" "adminpw" "collectingofficer" "${collectingofficer_dir}/ca" "${collectingofficer_tls}"

# Enroll CA Admin for evidencecustodianca
createEnrollment "5054" "admin" "adminpw" "evidencecustodian" "${evidencecustodian_dir}/ca" "${evidencecustodian_tls}"


######################################################################################
#  Create admin and user certificates for the Organizations
######################################################################################

# Enroll Admin certificate for the ordering service org
registerAndEnroll "5052" "osadmin" "osadminpw" "admin" "" "${orderer_org_dir}/users/Admin@example.com" "${orderer_org_dir}" "${orderer_org_tls}"

# Enroll Admin certificate for collectingofficer
registerAndEnroll "5053" "collectingofficeradmin" "collectingofficeradminpw" "admin" "collectingofficer" "${collectingofficer_dir}/users/Admin@collectingofficer.example.com" "${collectingofficer_dir}" "${collectingofficer_tls}"

# Enroll User certificate for collectingofficer
registerAndEnroll "5053" "collectingofficeruser1" "collectingofficeruser1pw" "client" "collectingofficer" "${collectingofficer_dir}/users/User1@collectingofficer.example.com" "${collectingofficer_dir}" "${collectingofficer_tls}"

# Enroll Admin certificate for evidencecustodian
registerAndEnroll "5054" "evidencecustodianadmin" "evidencecustodianadminpw" "admin" "evidencecustodian" "${evidencecustodian_dir}/users/Admin@evidencecustodian.example.com" "${evidencecustodian_dir}" "${evidencecustodian_tls}"

# Enroll User certificate for collectingofficer
registerAndEnroll "5054" "evidencecustodianuser1" "evidencecustodianuser1pw" "client" "evidencecustodian" "${evidencecustodian_dir}/users/User1@evidencecustodian.example.com" "${evidencecustodian_dir}" "${evidencecustodian_tls}"

######################################################################################
#  Create the certificates for the Ordering Organization
######################################################################################

# Create enrollment and TLS certificates for orderer1
registerAndEnroll "5052" "orderer1" "orderer1pw" "orderer" "" "${orderer1_dir}" "${orderer_org_dir}" "${orderer_org_tls}"

# Create enrollment and TLS certificates for orderer2
registerAndEnroll "5052" "orderer2" "orderer2pw" "orderer" "" "${orderer2_dir}" "${orderer_org_dir}" "${orderer_org_tls}"

# Create enrollment and TLS certificates for orderer3
registerAndEnroll "5052" "orderer3" "orderer3pw" "orderer" "" "${orderer3_dir}" "${orderer_org_dir}" "${orderer_org_tls}"

# Create enrollment and TLS certificates for orderer4
registerAndEnroll "5052" "orderer4" "orderer4pw" "orderer" "" "${orderer4_dir}" "${orderer_org_dir}" "${orderer_org_tls}"

# Create enrollment and TLS certificates for orderer5
registerAndEnroll "5052" "orderer5" "orderer5pw" "orderer" "" "${orderer5_dir}" "${orderer_org_dir}" "${orderer_org_tls}"


######################################################################################
#  Create the certificates for CollectingOfficer
######################################################################################

# Create enrollment and TLS certificates for peer0collectingofficer
registerAndEnroll "5053" "collectingofficerpeer0" "collectingofficerpeer0pw" "peer" "collectingofficer" "${peer0collectingofficer_dir}" "${collectingofficer_dir}" "${collectingofficer_tls}"

# Create enrollment and TLS certificates for peer1collectingofficer
registerAndEnroll "5053" "collectingofficerpeer1" "collectingofficerpeer1pw" "peer" "collectingofficer" "${peer1collectingofficer_dir}" "${collectingofficer_dir}" "${collectingofficer_tls}"


######################################################################################
#  Create the certificates for EvidenceCustodian
######################################################################################

# Create enrollment and TLS certificates for peer0evidencecustodian
registerAndEnroll "5054" "evidencecustodianpeer0" "evidencecustodianpeer0pw" "peer" "evidencecustodian" "${peer0evidencecustodian_dir}" "${evidencecustodian_dir}" "${evidencecustodian_tls}"

# Create enrollment and TLS certificates for peer1evidencecustodian
registerAndEnroll "5054" "evidencecustodianpeer1" "evidencecustodianpeer1pw" "peer" "evidencecustodian" "${peer1evidencecustodian_dir}" "${evidencecustodian_dir}" "${evidencecustodian_tls}"


######################################################################################
#  Create the Membership Service Providers (MSPs)
######################################################################################

# Create the MSP for the Orderering Org
createMSP "ordererca" "" "${orderer_org_dir}"

# Create the MSP for CollectingOfficer
createMSP "collectingofficerca" "collectingofficer" "${collectingofficer_dir}"

# Create the MSP for EvidenceCustodian
createMSP "evidencecustodianca" "evidencecustodian" "${evidencecustodian_dir}"

######################################################################################
#  Generate CCP files for CollectingOfficer and EvidenceCustodian
######################################################################################

# Generate CCP files for CollectingOfficer and EvidenceCustodian"
echo "Generating CCP files for CollectingOfficer and EvidenceCustodian"
./ca/ccp-generate.sh
echo "Generated CCP files for CollectingOfficer and EvidenceCustodian"
