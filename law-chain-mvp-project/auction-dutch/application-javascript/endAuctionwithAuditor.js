/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Gateway, Wallets } = require('fabric-network');
const path = require('path');
const { buildCCPCollectingOfficer, buildCCPEvidenceCustodian, buildWallet, prettyJSONString } = require('../../test-application/javascript/AppUtil.js');

const myChannel = 'mychannel';
const myChaincodeName = 'auction';

async function endAuction (ccp, wallet, org, user, auctionID) {
	try {
		const gateway = new Gateway();
		// connect using Discovery enabled

		await gateway.connect(ccp,
			{ wallet: wallet, identity: user, discovery: { enabled: true, asLocalhost: true } });

		const network = await gateway.getNetwork(myChannel);
		const contract = network.getContract(myChaincodeName);

		const statefulTxn = contract.createTransaction('EndAuction');

		statefulTxn.setEndorsingOrganizations(org, 'Org3MSP');

		console.log('\n--> Submit the transaction to end the auction');
		await statefulTxn.submit(auctionID);
		console.log('*** Result: committed');

		console.log('\n--> Evaluate Transaction: query the updated auction');
		const result = await contract.evaluateTransaction('QueryAuction', auctionID);
		console.log('*** Result: Auction: ' + prettyJSONString(result.toString()));

		gateway.disconnect();
	} catch (error) {
		console.error(`******** FAILED to submit bid: ${error}`);
		process.exit(1);
	}
}

async function main () {
	try {
		if (process.argv[2] === undefined || process.argv[3] === undefined ||
            process.argv[4] === undefined) {
			console.log('Usage: node endAuction.js org userID auctionID');
			process.exit(1);
		}

		const org = process.argv[2];
		const user = process.argv[3];
		const auctionID = process.argv[4];

		if (org === 'CollectingOfficer' || org === 'collectingofficer') {
			const orgMSP = 'CollectingOfficerMSP';
			const ccp = buildCCPCollectingOfficer();
			const walletPath = path.join(__dirname, 'wallet/collectingofficer');
			const wallet = await buildWallet(Wallets, walletPath);
			await endAuction(ccp, wallet, orgMSP, user, auctionID);
		} else if (org === 'EvidenceCustodian' || org === 'evidencecustodian') {
			const orgMSP = 'EvidenceCustodianMSP';
			const ccp = buildCCPEvidenceCustodian();
			const walletPath = path.join(__dirname, 'wallet/evidencecustodian');
			const wallet = await buildWallet(Wallets, walletPath);
			await endAuction(ccp, wallet, orgMSP, user, auctionID);
		} else {
			console.log('Usage: node endAuction.js org userID auctionID');
			console.log('Org must be CollectingOfficer or EvidenceCustodian');
		}
	} catch (error) {
		console.error(`******** FAILED to run the application: ${error}`);
		if (error.stack) {
			console.error(error.stack);
		}
		process.exit(1);
	}
}

main();
