/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Wallets } = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const path = require('path');
const { buildCAClient, registerAndEnrollUser } = require('../../test-application/javascript/CAUtil.js');
const { buildCCPCollectingOfficer, buildCCPEvidenceCustodian, buildWallet } = require('../../test-application/javascript/AppUtil.js');

const mspCollectingOfficer = 'CollectingOfficerMSP';
const mspEvidenceCustodian = 'EvidenceCustodianMSP';

async function connectToCollectingOfficerCA (UserID) {
	console.log('\n--> Register and enrolling new user');
	const ccpCollectingOfficer = buildCCPCollectingOfficer();
	const caCollectingOfficerClient = buildCAClient(FabricCAServices, ccpCollectingOfficer, 'ca.collectingofficer.example.com');

	const walletPathCollectingOfficer = path.join(__dirname, 'wallet/collectingofficer');
	const walletCollectingOfficer = await buildWallet(Wallets, walletPathCollectingOfficer);

	await registerAndEnrollUser(caCollectingOfficerClient, walletCollectingOfficer, mspCollectingOfficer, UserID, 'collectingofficer.department1');
}

async function connectToEvidenceCustodianCA (UserID) {
	console.log('\n--> Register and enrolling new user');
	const ccpEvidenceCustodian = buildCCPEvidenceCustodian();
	const caEvidenceCustodianClient = buildCAClient(FabricCAServices, ccpEvidenceCustodian, 'ca.evidencecustodian.example.com');

	const walletPathEvidenceCustodian = path.join(__dirname, 'wallet/evidencecustodian');
	const walletEvidenceCustodian = await buildWallet(Wallets, walletPathEvidenceCustodian);

	await registerAndEnrollUser(caEvidenceCustodianClient, walletEvidenceCustodian, mspEvidenceCustodian, UserID, 'evidencecustodian.department1');
}
async function main () {
	if (process.argv[2] === undefined && process.argv[3] === undefined) {
		console.log('Usage: node registerEnrollUser.js org userID');
		process.exit(1);
	}

	const org = process.argv[2];
	const userId = process.argv[3];

	try {
		if (org === 'CollectingOfficer' || org === 'collectingofficer') {
			await connectToCollectingOfficerCA(userId);
		} else if (org === 'EvidenceCustodian' || org === 'evidencecustodian') {
			await connectToEvidenceCustodianCA(userId);
		} else {
			console.log('Usage: node registerEnrollUser.js org userID');
			console.log('Org must be CollectingOfficer or EvidenceCustodian');
		}
	} catch (error) {
		console.error(`Error in enrolling admin: ${error}`);
		process.exit(1);
	}
}

main();
