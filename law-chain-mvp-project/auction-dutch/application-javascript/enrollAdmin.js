/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Wallets } = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const path = require('path');
const { buildCAClient, enrollAdmin } = require('../../test-application/javascript/CAUtil.js');
const { buildCCPCollectingOfficer, buildCCPEvidenceCustodian, buildWallet } = require('../../test-application/javascript/AppUtil.js');

const mspCollectingOfficer = 'CollectingOfficerMSP';
const mspEvidenceCustodian = 'EvidenceCustodianMSP';

async function connectToCollectingOfficerCA () {
	console.log('\n--> Enrolling the CollectingOfficer CA admin');
	const ccpCollectingOfficer = buildCCPCollectingOfficer();
	const caCollectingOfficerClient = buildCAClient(FabricCAServices, ccpCollectingOfficer, 'ca.collectingofficer.example.com');

	const walletPathCollectingOfficer = path.join(__dirname, 'wallet/collectingofficer');
	const walletCollectingOfficer = await buildWallet(Wallets, walletPathCollectingOfficer);

	await enrollAdmin(caCollectingOfficerClient, walletCollectingOfficer, mspCollectingOfficer);
}

async function connectToEvidenceCustodianCA () {
	console.log('\n--> Enrolling the EvidenceCustodian CA admin');
	const ccpEvidenceCustodian = buildCCPEvidenceCustodian();
	const caEvidenceCustodianClient = buildCAClient(FabricCAServices, ccpEvidenceCustodian, 'ca.evidencecustodian.example.com');

	const walletPathEvidenceCustodian = path.join(__dirname, 'wallet/evidencecustodian');
	const walletEvidenceCustodian = await buildWallet(Wallets, walletPathEvidenceCustodian);

	await enrollAdmin(caEvidenceCustodianClient, walletEvidenceCustodian, mspEvidenceCustodian);
}
async function main () {
	if (process.argv[2] === undefined) {
		console.log('Usage: node enrollAdmin.js Org');
		process.exit(1);
	}

	const org = process.argv[2];

	try {
		if (org === 'CollectingOfficer' || org === 'collectingofficer') {
			await connectToCollectingOfficerCA();
		} else if (org === 'EvidenceCustodian' || org === 'evidencecustodian') {
			await connectToEvidenceCustodianCA();
		} else {
			console.log('Usage: node registerUser.js org userID');
			console.log('Org must be CollectingOfficer or EvidenceCustodian');
		}
	} catch (error) {
		console.error(`Error in enrolling admin: ${error}`);
		process.exit(1);
	}
}

main();
