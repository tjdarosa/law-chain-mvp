/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import * as grpc from '@grpc/grpc-js';
import { Identity, Signer, signers } from '@hyperledger/fabric-gateway';
import * as crypto from 'crypto';
import { promises as fs } from 'fs';
import * as path from 'path';

// MSP Id's of Organizations
export const mspIdCollectingOfficer = 'CollectingOfficerMSP';
export const mspIdEvidenceCustodian = 'EvidenceCustodianMSP';

// Path to collectingofficer crypto materials.
export const cryptoPathCollectingOfficer = path.resolve(__dirname, '..', '..', '..', 'test-network', 'organizations', 'peerOrganizations', 'collectingofficer.example.com');

// Path to user private key directory.
export const keyDirectoryPathCollectingOfficer = path.resolve(cryptoPathCollectingOfficer, 'users', 'User1@collectingofficer.example.com', 'msp', 'keystore');

// Path to user certificate.
export const certDirectoryPathCollectingOfficer = path.resolve(cryptoPathCollectingOfficer, 'users', 'User1@collectingofficer.example.com', 'msp', 'signcerts');

// Path to peer tls certificate.
export const tlsCertPathCollectingOfficer = path.resolve(cryptoPathCollectingOfficer, 'peers', 'peer0.collectingofficer.example.com', 'tls', 'ca.crt');

// Path to evidencecustodian crypto materials.
export const cryptoPathEvidenceCustodian = path.resolve(
    __dirname,
    '..',
    '..',
    '..',
    'test-network',
    'organizations',
    'peerOrganizations',
    'evidencecustodian.example.com'
);

// Path to evidencecustodian user private key directory.
export const keyDirectoryPathEvidenceCustodian = path.resolve(
    cryptoPathEvidenceCustodian,
    'users',
    'User1@evidencecustodian.example.com',
    'msp',
    'keystore'
);

// Path to evidencecustodian user certificate.
export const certDirectoryPathEvidenceCustodian = path.resolve(
    cryptoPathEvidenceCustodian,
    'users',
    'User1@evidencecustodian.example.com',
    'msp',
    'signcerts'
);

// Path to evidencecustodian peer tls certificate.
export const tlsCertPathEvidenceCustodian = path.resolve(
    cryptoPathEvidenceCustodian,
    'peers',
    'peer0.evidencecustodian.example.com',
    'tls',
    'ca.crt'
);
// Gateway peer endpoint.
export const peerEndpointCollectingOfficer = 'localhost:7051';
export const peerEndpointEvidenceCustodian = 'localhost:9051';

// Gateway peer container name.
export const peerNameCollectingOfficer = 'peer0.collectingofficer.example.com';
export const peerNameEvidenceCustodian = 'peer0.evidencecustodian.example.com';

// Collection Names
export const collectingofficerPrivateCollectionName = 'CollectingOfficerMSPPrivateCollection';
export const evidencecustodianPrivateCollectionName = 'EvidenceCustodianMSPPrivateCollection';

export async function newGrpcConnection(
    tlsCertPath: string,
    peerEndpoint: string,
    peerName: string
): Promise<grpc.Client> {
    const tlsRootCert = await fs.readFile(tlsCertPath);
    const tlsCredentials = grpc.credentials.createSsl(tlsRootCert);
    return new grpc.Client(peerEndpoint, tlsCredentials, {
        'grpc.ssl_target_name_override': peerName,
    });
}

export async function newIdentity(certDirectoryPath: string, mspId: string): Promise<Identity> {
    const certPath = await getFirstDirFileName(certDirectoryPath);
    const credentials = await fs.readFile(certPath);
    return { mspId, credentials };
}

export async function newSigner(keyDirectoryPath: string): Promise<Signer> {
    const keyPath = await getFirstDirFileName(keyDirectoryPath);
    const privateKeyPem = await fs.readFile(keyPath);
    const privateKey = crypto.createPrivateKey(privateKeyPem);
    return signers.newPrivateKeySigner(privateKey);
}

async function getFirstDirFileName(dirPath: string): Promise<string> {
    const files = await fs.readdir(dirPath);
    const file = files[0];
    if (!file) {
        throw new Error(`No files in directory: ${dirPath}`);
    }
    return path.join(dirPath, file);
}
