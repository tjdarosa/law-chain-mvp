/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

/**
 * A test application to show state based endorsements operations with a running
 * asset-transfer-sbe chaincode with discovery.
 *   -- How to submit a transaction
 *   -- How to query
 *   -- How to limit the organizations involved in a transaction
 *
 * To see the SDK workings, try setting the logging to show on the console before running
 *        export HFC_LOGGING='{"debug":"console"}'
 */

// pre-requisites:
// - fabric-sample two organization test-network setup with two peers, ordering service,
//   and 2 certificate authorities
//         ===> from directory /fabric-samples/test-network
//         ./network.sh up createChannel -ca
// - Use any of the asset-transfer-sbe chaincodes deployed on the channel "mychannel"
//   with the chaincode name of "sbe". The following deploy command will package,
//   install, approve, and commit the javascript chaincode, all the actions it takes
//   to deploy a chaincode to a channel.
//         ===> from directory /fabric-samples/test-network
//         ./network.sh deployCC -ccn sbe -ccp ../asset-transfer-sbe/chaincode-typescript/ -ccl typescript
// - Be sure that node.js is installed
//         ===> from directory /fabric-samples/asset-transfer-sbe/application-javascript
//         node -v
// - npm installed code dependencies
//         ===> from directory /fabric-samples/asset-transfer-sbe/application-javascript
//         npm install
// - to run this test application
//         ===> from directory /fabric-samples/asset-transfer-sbe/application-javascript
//         node app.js

// NOTE: If you see an error like these:
/*

   Error in setup: Error: DiscoveryService: mychannel error: access denied

   OR

   Failed to register user : Error: fabric-ca request register failed with errors [[ { code: 20, message: 'Authentication failure' } ]]

	*/
// Delete the /fabric-samples/asset-transfer-sbe/application-javascript/wallet directory
// and retry this application.
//
// The certificate authority must have been restarted and the saved certificates for the
// admin and application user are not valid. Deleting the wallet store will force these to be reset
// with the new certificate authority.
//

const { Gateway, Wallets } = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const path = require('path');
const { buildCAClient, registerAndEnrollUser, enrollAdmin } = require('../../test-application/javascript/CAUtil.js');
const { buildCCPCollectingOfficer, buildCCPEvidenceCustodian, buildWallet } = require('../../test-application/javascript/AppUtil.js');

const channelName = 'mychannel';
const chaincodeName = 'sbe';

const collectingofficer = 'CollectingOfficerMSP';
const evidencecustodian = 'EvidenceCustodianMSP';
const CollectingOfficerUserId = 'appUser1';
const EvidenceCustodianUserId = 'appUser2';

async function initGatewayForCollectingOfficer() {
	console.log('\n--> Fabric client user & Gateway init: Using CollectingOfficer identity to CollectingOfficer Peer');
	// build an in memory object with the network configuration (also known as a connection profile)
	const ccpCollectingOfficer = buildCCPCollectingOfficer();

	// build an instance of the fabric ca services client based on
	// the information in the network configuration
	const caCollectingOfficerClient = buildCAClient(FabricCAServices, ccpCollectingOfficer, 'ca.collectingofficer.example.com');

	// setup the wallet to cache the credentials of the application user, on the app server locally
	const walletPathCollectingOfficer = path.join(__dirname, 'wallet', 'collectingofficer');
	const walletCollectingOfficer = await buildWallet(Wallets, walletPathCollectingOfficer);

	// in a real application this would be done on an administrative flow, and only once
	// stores admin identity in local wallet, if needed
	await enrollAdmin(caCollectingOfficerClient, walletCollectingOfficer, collectingofficer);
	// register & enroll application user with CA, which is used as client identify to make chaincode calls
	// and stores app user identity in local wallet
	// In a real application this would be done only when a new user was required to be added
	// and would be part of an administrative flow
	await registerAndEnrollUser(caCollectingOfficerClient, walletCollectingOfficer, collectingofficer, CollectingOfficerUserId, 'collectingofficer.department1');

	try {
		// Create a new gateway for connecting to Org's peer node.
		const gatewayCollectingOfficer = new Gateway();
		//connect using Discovery enabled
		await gatewayCollectingOfficer.connect(ccpCollectingOfficer,
			{ wallet: walletCollectingOfficer, identity: CollectingOfficerUserId, discovery: { enabled: true, asLocalhost: true } });

		return gatewayCollectingOfficer;
	} catch (error) {
		console.error(`Error in connecting to gateway for CollectingOfficer: ${error}`);
		process.exit(1);
	}
}

async function initGatewayForEvidenceCustodian() {
	console.log('\n--> Fabric client user & Gateway init: Using EvidenceCustodian identity to EvidenceCustodian Peer');
	const ccpEvidenceCustodian = buildCCPEvidenceCustodian();
	const caEvidenceCustodianClient = buildCAClient(FabricCAServices, ccpEvidenceCustodian, 'ca.evidencecustodian.example.com');

	const walletPathEvidenceCustodian = path.join(__dirname, 'wallet', 'evidencecustodian');
	const walletEvidenceCustodian = await buildWallet(Wallets, walletPathEvidenceCustodian);

	await enrollAdmin(caEvidenceCustodianClient, walletEvidenceCustodian, evidencecustodian);
	await registerAndEnrollUser(caEvidenceCustodianClient, walletEvidenceCustodian, evidencecustodian, EvidenceCustodianUserId, 'evidencecustodian.department1');

	try {
		// Create a new gateway for connecting to Org's peer node.
		const gatewayEvidenceCustodian = new Gateway();
		await gatewayEvidenceCustodian.connect(ccpEvidenceCustodian,
			{ wallet: walletEvidenceCustodian, identity: EvidenceCustodianUserId, discovery: { enabled: true, asLocalhost: true } });

		return gatewayEvidenceCustodian;
	} catch (error) {
		console.error(`Error in connecting to gateway for EvidenceCustodian: ${error}`);
		process.exit(1);
	}
}

function checkAsset(org, assetKey, resultBuffer, value, ownerOrg) {
	let asset;
	if (resultBuffer) {
		asset = JSON.parse(resultBuffer.toString('utf8'));
	}

	if (asset && value) {
		if (asset.Value === value && asset.OwnerOrg === ownerOrg) {
			console.log(`*** Result from ${org} - asset ${asset.ID} has value of ${asset.Value} and owned by ${asset.OwnerOrg}`);
		} else {
			console.log(`*** Failed from ${org} - asset ${asset.ID} has value of ${asset.Value} and owned by ${asset.OwnerOrg}`);
		}
	} else if (!asset && value === 0 ) {
		console.log(`*** Success from ${org} - asset ${assetKey} does not exist`);
	} else {
		console.log('*** Failed - asset read failed');
	}
}

async function readAssetByBothOrgs(assetKey, value, ownerOrg, contractCollectingOfficer, contractEvidenceCustodian) {
	if (value) {
		console.log(`\n--> Evaluate Transaction: ReadAsset, - ${assetKey} should have a value of ${value} and owned by ${ownerOrg}`);
	} else {
		console.log(`\n--> Evaluate Transaction: ReadAsset, - ${assetKey} should not exist`);
	}
	let resultBuffer;
	resultBuffer = await contractCollectingOfficer.evaluateTransaction('ReadAsset', assetKey);
	checkAsset('CollectingOfficer', assetKey, resultBuffer, value, ownerOrg);
	resultBuffer = await contractEvidenceCustodian.evaluateTransaction('ReadAsset', assetKey);
	checkAsset('EvidenceCustodian', assetKey, resultBuffer, value, ownerOrg);
}

// This application uses fabric-samples/test-network based setup and the companion chaincode
// For this illustration, both CollectingOfficer & EvidenceCustodian client identities will be used, however
// notice they are used by two different "gateway"s to simulate two different running
// applications from two different organizations.
async function main() {
	try {
		// use a random key so that we can run multiple times
		const assetKey = `asset-${Math.floor(Math.random() * 100) + 1}`;

		/** ******* Fabric client init: Using CollectingOfficer identity to CollectingOfficer Peer ******* */
		const gatewayCollectingOfficer = await initGatewayForCollectingOfficer();
		const networkCollectingOfficer = await gatewayCollectingOfficer.getNetwork(channelName);
		const contractCollectingOfficer = networkCollectingOfficer.getContract(chaincodeName);

		/** ******* Fabric client init: Using EvidenceCustodian identity to EvidenceCustodian Peer ******* */
		const gatewayEvidenceCustodian = await initGatewayForEvidenceCustodian();
		const networkEvidenceCustodian = await gatewayEvidenceCustodian.getNetwork(channelName);
		const contractEvidenceCustodian = networkEvidenceCustodian.getContract(chaincodeName);

		try {
			let transaction;

			try {
				// Create an asset by organization CollectingOfficer, this will require that both organization endorse.
				// The endorsement will be handled by Discovery, since the gateway was connected with discovery enabled.
				console.log(`\n--> Submit Transaction: CreateAsset, ${assetKey} as CollectingOfficer - endorsed by CollectingOfficer and EvidenceCustodian`);
				await contractCollectingOfficer.submitTransaction('CreateAsset', assetKey, '100', 'Tom');
				console.log('*** Result: committed, now asset will only require CollectingOfficer to endorse');
			} catch (createError) {
				console.log(`*** Failed: create - ${createError}`);
				process.exit(1);
			}

			await readAssetByBothOrgs(assetKey, 100, collectingofficer, contractCollectingOfficer, contractEvidenceCustodian);

			try {
				// Since the gateway is using discovery we should limit the organizations used by
				// discovery to endorse. This way we only have to know the organization and not
				// the actual peers that may be active at any given time.
				console.log(`\n--> Submit Transaction: UpdateAsset ${assetKey}, as CollectingOfficer - endorse by CollectingOfficer`);
				transaction = contractCollectingOfficer.createTransaction('UpdateAsset');
				transaction.setEndorsingOrganizations(collectingofficer);
				await transaction.submit(assetKey, '200');
				console.log('*** Result: committed');
			} catch (updateError) {
				console.log(`*** Failed: update - ${updateError}`);
				process.exit(1);
			}

			await readAssetByBothOrgs(assetKey, 200, collectingofficer, contractCollectingOfficer, contractEvidenceCustodian);

			try {
				// Submit a transaction to make an update to the asset that has a key-level endorsement policy
				// set to only allow CollectingOfficer to make updates. The following example will not use the "setEndorsingOrganizations"
				// to limit the organizations that will do the endorsement, this means that it will be sent to all
				// organizations in the chaincode endorsement policy. When CollectingOfficer endorses, the transaction will be committed
				// if EvidenceCustodian endorses or not.
				console.log(`\n--> Submit Transaction: UpdateAsset ${assetKey}, as CollectingOfficer - endorse by CollectingOfficer and EvidenceCustodian`);
				transaction = contractCollectingOfficer.createTransaction('UpdateAsset');
				await transaction.submit(assetKey, '300');
				console.log('*** Result: committed - because CollectingOfficer and EvidenceCustodian both endorsed, while only the CollectingOfficer endorsement was required and checked');
			} catch (updateError) {
				console.log(`*** Failed: update - ${updateError}`);
				process.exit(1);
			}

			await readAssetByBothOrgs(assetKey, 300, collectingofficer, contractCollectingOfficer, contractEvidenceCustodian);

			try {
				// Again submit the change to both Organizations by not using "setEndorsingOrganizations". Since only
				// CollectingOfficer is required to approve, the transaction will be committed.
				console.log(`\n--> Submit Transaction: UpdateAsset ${assetKey}, as EvidenceCustodian - endorse by CollectingOfficer and EvidenceCustodian`);
				transaction = contractEvidenceCustodian.createTransaction('UpdateAsset');
				await transaction.submit(assetKey, '400');
				console.log('*** Result: committed - because CollectingOfficer was on the discovery list, EvidenceCustodian did not endorse');
			} catch (updateError) {
				console.log(`*** Failed: update - ${updateError}`);
				process.exit(1);
			}

			await readAssetByBothOrgs(assetKey, 400, collectingofficer, contractCollectingOfficer, contractEvidenceCustodian);

			try {
				// Try to update by sending only to EvidenceCustodian, since the state-based-endorsement says that
				// CollectingOfficer is the only organization allowed to update, the transaction will fail.
				console.log(`\n--> Submit Transaction: UpdateAsset ${assetKey}, as EvidenceCustodian - endorse by EvidenceCustodian`);
				transaction = contractEvidenceCustodian.createTransaction('UpdateAsset');
				transaction.setEndorsingOrganizations(evidencecustodian);
				await transaction.submit(assetKey, '500');
				console.log('*** Failed: committed - this should have failed to endorse and commit');
			} catch (updateError) {
				console.log(`*** Successfully caught the error: \n    ${updateError}`);
			}

			await readAssetByBothOrgs(assetKey, 400, collectingofficer, contractCollectingOfficer, contractEvidenceCustodian);

			try {
				// Make a change to the state-based-endorsement policy making EvidenceCustodian the owner.
				console.log(`\n--> Submit Transaction: TransferAsset ${assetKey}, as CollectingOfficer - endorse by CollectingOfficer`);
				transaction = contractCollectingOfficer.createTransaction('TransferAsset');
				transaction.setEndorsingOrganizations(collectingofficer);
				await transaction.submit(assetKey, 'Henry', evidencecustodian);
				console.log('*** Result: committed');
			} catch (transferError) {
				console.log(`*** Failed: transfer - ${transferError}`);
				process.exit(1);
			}

			await readAssetByBothOrgs(assetKey, 400, evidencecustodian, contractCollectingOfficer, contractEvidenceCustodian);

			try {
				// Make sure that EvidenceCustodian can now make updates, notice how the transaction has limited the
				// endorsement to only EvidenceCustodian.
				console.log(`\n--> Submit Transaction: UpdateAsset ${assetKey}, as EvidenceCustodian - endorse by EvidenceCustodian`);
				transaction = contractEvidenceCustodian.createTransaction('UpdateAsset');
				transaction.setEndorsingOrganizations(evidencecustodian);
				await transaction.submit(assetKey, '600');
				console.log('*** Result: committed');
			} catch (updateError) {
				console.log(`*** Failed: update - ${updateError}`);
				process.exit(1);
			}

			await readAssetByBothOrgs(assetKey, 600, evidencecustodian, contractCollectingOfficer, contractEvidenceCustodian);

			try {
				// With EvidenceCustodian now the owner and the state-based-endorsement policy only allowing organization EvidenceCustodian
				// to make updates, a transaction only to CollectingOfficer will fail.
				console.log(`\n--> Submit Transaction: UpdateAsset ${assetKey}, as CollectingOfficer - endorse by CollectingOfficer`);
				transaction = contractCollectingOfficer.createTransaction('UpdateAsset');
				transaction.setEndorsingOrganizations(collectingofficer);
				await transaction.submit(assetKey, '700');
				console.log('*** Failed: committed - this should have failed to endorse and commit');
			} catch (updateError) {
				console.log(`*** Successfully caught the error: \n    ${updateError}`);
			}

			await readAssetByBothOrgs(assetKey, 600, evidencecustodian, contractCollectingOfficer, contractEvidenceCustodian);

			try {
				// With EvidenceCustodian the owner and the state-based-endorsement policy only allowing organization EvidenceCustodian
				// to make updates, a transaction to delete by CollectingOfficer will fail.
				console.log(`\n--> Submit Transaction: DeleteAsset ${assetKey}, as CollectingOfficer - endorse by CollectingOfficer`);
				transaction = contractCollectingOfficer.createTransaction('DeleteAsset');
				transaction.setEndorsingOrganizations(collectingofficer);
				await transaction.submit(assetKey);
				console.log('*** Failed: committed - this should have failed to endorse and commit');
			} catch (updateError) {
				console.log(`*** Successfully caught the error: \n    ${updateError}`);
			}

			try {
				// With EvidenceCustodian the owner and the state-based-endorsement policy only allowing organization EvidenceCustodian
				// to make updates, a transaction to delete by EvidenceCustodian will succeed.
				console.log(`\n--> Submit Transaction: DeleteAsset ${assetKey}, as EvidenceCustodian - endorse by EvidenceCustodian`);
				transaction = contractEvidenceCustodian.createTransaction('DeleteAsset');
				transaction.setEndorsingOrganizations(evidencecustodian);
				await transaction.submit(assetKey);
				console.log('*** Result: committed');
			} catch (deleteError) {
				console.log(`*** Failed: delete - ${deleteError}`);
				process.exit(1);
			}

			// The asset should now be deleted, both orgs should not be able to read it
			try {
				await readAssetByBothOrgs(assetKey, 0, evidencecustodian, contractCollectingOfficer, contractEvidenceCustodian);
			} catch (readDeleteError) {
				console.log(`*** Successfully caught the error: ${readDeleteError}`);
			}

		} catch (runError) {
			console.error(`Error in transaction: ${runError}`);
			if (runError.stack) {
				console.error(runError.stack);
			}
			process.exit(1);
		} finally {
			// Disconnect from the gateway peer when all work for this client identity is complete
			gatewayCollectingOfficer.disconnect();
			gatewayEvidenceCustodian.disconnect();
		}
	} catch (error) {
		console.error(`Error in setup: ${error}`);
		if (error.stack) {
			console.error(error.stack);
		}
		process.exit(1);
	}
}

main();
