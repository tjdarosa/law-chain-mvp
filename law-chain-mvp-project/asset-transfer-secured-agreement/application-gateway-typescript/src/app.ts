/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import { connect, hash } from '@hyperledger/fabric-gateway';

import { newGrpcConnection, newIdentity, newSigner, tlsCertPathCollectingOfficer, peerEndpointCollectingOfficer, peerNameCollectingOfficer, certDirectoryPathCollectingOfficer, mspIdCollectingOfficer, keyDirectoryPathCollectingOfficer, tlsCertPathEvidenceCustodian, peerEndpointEvidenceCustodian, peerNameEvidenceCustodian, certDirectoryPathEvidenceCustodian, mspIdEvidenceCustodian, keyDirectoryPathEvidenceCustodian } from './connect';
import { ContractWrapper } from './contractWrapper';
import { RED, RESET } from './utils';

const channelName = 'mychannel';
const chaincodeName = 'secured';

// Use a random key so that we can run multiple times
const now = Date.now().toString();
let assetKey: string;

async function main(): Promise<void> {

    // The gRPC client connection from collectingofficer should be shared by all Gateway connections to this endpoint.
    const clientCollectingOfficer = await newGrpcConnection(
        tlsCertPathCollectingOfficer,
        peerEndpointCollectingOfficer,
        peerNameCollectingOfficer
    );

    const gatewayCollectingOfficer = connect({
        client: clientCollectingOfficer,
        identity: await newIdentity(certDirectoryPathCollectingOfficer, mspIdCollectingOfficer),
        signer: await newSigner(keyDirectoryPathCollectingOfficer),
        hash: hash.sha256,
    });

    // The gRPC client connection from evidencecustodian should be shared by all Gateway connections to this endpoint.
    const clientEvidenceCustodian = await newGrpcConnection(
        tlsCertPathEvidenceCustodian,
        peerEndpointEvidenceCustodian,
        peerNameEvidenceCustodian
    );

    const gatewayEvidenceCustodian = connect({
        client: clientEvidenceCustodian,
        identity: await newIdentity(certDirectoryPathEvidenceCustodian, mspIdEvidenceCustodian),
        signer: await newSigner(keyDirectoryPathEvidenceCustodian),
        hash: hash.sha256,
    });


    try {

        // Get the smart contract from the network for CollectingOfficer.
        const contractCollectingOfficer = gatewayCollectingOfficer.getNetwork(channelName).getContract(chaincodeName);
        const contractWrapperCollectingOfficer  = new ContractWrapper(contractCollectingOfficer, mspIdCollectingOfficer);

        // Get the smart contract from the network for EvidenceCustodian.
        const contractEvidenceCustodian = gatewayEvidenceCustodian.getNetwork(channelName).getContract(chaincodeName);
        const contractWrapperEvidenceCustodian  = new ContractWrapper(contractEvidenceCustodian, mspIdEvidenceCustodian);

        // Create an asset by organization CollectingOfficer, this only requires the owning organization to endorse.
        assetKey = await contractWrapperCollectingOfficer.createAsset(mspIdCollectingOfficer,
            `Asset owned by ${mspIdCollectingOfficer} is not for sale`, { ObjectType: 'asset_properties', Color: 'blue', Size: 35 });

        // Read the public details by collectingofficer.
        await contractWrapperCollectingOfficer.readAsset(assetKey, mspIdCollectingOfficer);

        // Read the public details by evidencecustodian.
        await contractWrapperEvidenceCustodian.readAsset(assetKey, mspIdCollectingOfficer);

        // CollectingOfficer should be able to read the private data details of the asset.
        await contractWrapperCollectingOfficer.getAssetPrivateProperties(assetKey, mspIdCollectingOfficer);

        // EvidenceCustodian is not the owner and does not have the private details, read expected to fail.
        try {
            await contractWrapperEvidenceCustodian.getAssetPrivateProperties(assetKey, mspIdCollectingOfficer);
        } catch (e) {
            console.log(`${RED}*** Successfully caught the failure: getAssetPrivateProperties - ${String(e)}${RESET}`);
        }

        // CollectingOfficer updates the assets public description.
        await contractWrapperCollectingOfficer.changePublicDescription({assetId: assetKey,
            ownerOrg: mspIdCollectingOfficer,
            publicDescription: `Asset ${assetKey} owned by ${mspIdCollectingOfficer} is for sale`});

        // Read the public details by collectingofficer.
        await contractWrapperCollectingOfficer.readAsset(assetKey, mspIdCollectingOfficer);

        // Read the public details by evidencecustodian.
        await contractWrapperEvidenceCustodian.readAsset(assetKey, mspIdCollectingOfficer);

        // This is an update to the public state and requires the owner(CollectingOfficer) to endorse and sent by the owner org client (CollectingOfficer).
        // Since the client is from EvidenceCustodian, which is not the owner, this will fail.
        try{
            await contractWrapperEvidenceCustodian.changePublicDescription({assetId: assetKey,
                ownerOrg: mspIdCollectingOfficer,
                publicDescription: `Asset ${assetKey} owned by ${mspIdEvidenceCustodian} is NOT for sale`});
        } catch(e) {
            console.log(`${RED}*** Successfully caught the failure: changePublicDescription - ${String(e)}${RESET}`);
        }

        // Read the public details by collectingofficer.
        await contractWrapperCollectingOfficer.readAsset(assetKey, mspIdCollectingOfficer);

        // Read the public details by evidencecustodian.
        await contractWrapperEvidenceCustodian.readAsset(assetKey, mspIdCollectingOfficer);

        // Agree to a sell by collectingofficer.
        await contractWrapperCollectingOfficer.agreeToSell({
            assetId: assetKey,
            price: 110,
            tradeId: now,
        });

        // Check the private information about the asset from EvidenceCustodian. CollectingOfficer would have to send EvidenceCustodian asset details,
        // so the hash of the details may be checked by the chaincode.
        await contractWrapperEvidenceCustodian.verifyAssetProperties(assetKey, {color:'blue', size:35});

        // Agree to a buy by evidencecustodian.
        await contractWrapperEvidenceCustodian.agreeToBuy( {assetId: assetKey,
            price: 100,
            tradeId: now}, { ObjectType: 'asset_properties', Color: 'blue', Size: 35 });

        // CollectingOfficer should be able to read the sale price of this asset.
        await contractWrapperCollectingOfficer.getAssetSalesPrice(assetKey, mspIdCollectingOfficer);

        // EvidenceCustodian has not set a sale price and this should fail.
        try{
            await contractWrapperEvidenceCustodian.getAssetSalesPrice(assetKey, mspIdCollectingOfficer);
        } catch(e) {
            console.log(`${RED}*** Successfully caught the failure: getAssetSalesPrice - ${String(e)}${RESET}`);
        }

        // CollectingOfficer has not agreed to buy so this should fail.
        try{
            await contractWrapperCollectingOfficer.getAssetBidPrice(assetKey, mspIdEvidenceCustodian);
        } catch(e) {
            console.log(`${RED}*** Successfully caught the failure: getAssetBidPrice - ${String(e)}${RESET}`);
        }
        // EvidenceCustodian should be able to see the price it has agreed.
        await contractWrapperEvidenceCustodian.getAssetBidPrice(assetKey, mspIdEvidenceCustodian);

        // CollectingOfficer will try to transfer the asset to EvidenceCustodian
        // This will fail due to the sell price and the bid price are not the same.
        try{
            await contractWrapperCollectingOfficer.transferAsset({ assetId: assetKey, price: 110, tradeId: now}, [ mspIdCollectingOfficer, mspIdEvidenceCustodian ], mspIdCollectingOfficer, mspIdEvidenceCustodian);
        } catch(e) {
            console.log(`${RED}*** Successfully caught the failure: transferAsset - ${String(e)}${RESET}`);
        }
        // Agree to a sell by CollectingOfficer, the seller will agree to the bid price of EvidenceCustodian.
        await contractWrapperCollectingOfficer.agreeToSell({assetId:assetKey, price:100, tradeId:now});

        // Read the public details by  collectingofficer.
        await contractWrapperCollectingOfficer.readAsset(assetKey, mspIdCollectingOfficer);

        // Read the public details by  evidencecustodian.
        await contractWrapperEvidenceCustodian.readAsset(assetKey, mspIdCollectingOfficer);

        // CollectingOfficer should be able to read the private data details of the asset.
        await contractWrapperCollectingOfficer.getAssetPrivateProperties(assetKey, mspIdCollectingOfficer);

        // CollectingOfficer should be able to read the sale price of this asset.
        await contractWrapperCollectingOfficer.getAssetSalesPrice(assetKey, mspIdCollectingOfficer);

        // EvidenceCustodian should be able to see the price it has agreed.
        await contractWrapperEvidenceCustodian.getAssetBidPrice(assetKey, mspIdEvidenceCustodian);

        // EvidenceCustodian user will try to transfer the asset to CollectingOfficer.
        // This will fail as the owner is CollectingOfficer.
        try{
            await contractWrapperEvidenceCustodian.transferAsset({ assetId: assetKey, price: 100, tradeId: now}, [ mspIdCollectingOfficer, mspIdEvidenceCustodian ], mspIdCollectingOfficer, mspIdEvidenceCustodian);
        } catch(e) {
            console.log(`${RED}*** Successfully caught the failure: transferAsset - ${String(e)}${RESET}`);
        }

        // CollectingOfficer will transfer the asset to EvidenceCustodian.
        // This will now complete as the sell price and the bid price are the same.
        await contractWrapperCollectingOfficer.transferAsset({ assetId: assetKey, price: 100, tradeId: now}, [ mspIdCollectingOfficer, mspIdEvidenceCustodian ], mspIdCollectingOfficer, mspIdEvidenceCustodian);

        // Read the public details by  collectingofficer.
        await contractWrapperCollectingOfficer.readAsset(assetKey, mspIdEvidenceCustodian);

        // Read the public details by  evidencecustodian.
        await contractWrapperEvidenceCustodian.readAsset(assetKey, mspIdEvidenceCustodian);

        // EvidenceCustodian should be able to read the private data details of this asset.
        await contractWrapperEvidenceCustodian.getAssetPrivateProperties(assetKey, mspIdEvidenceCustodian);

        // CollectingOfficer should not be able to read the private data details of this asset, expected to fail.
        try{
            await contractWrapperCollectingOfficer.getAssetPrivateProperties(assetKey, mspIdEvidenceCustodian);
        } catch(e) {
            console.log(`${RED}*** Successfully caught the failure: getAssetPrivateProperties - ${String(e)}${RESET}`);
        }

        // This is an update to the public state and requires only the owner to endorse.
        // EvidenceCustodian wants to indicate that the items is no longer for sale.
        await contractWrapperEvidenceCustodian.changePublicDescription( {assetId: assetKey, ownerOrg: mspIdEvidenceCustodian, publicDescription: `Asset ${assetKey} owned by ${mspIdEvidenceCustodian} is NOT for sale`});

        // Read the public details by collectingofficer.
        await contractWrapperCollectingOfficer.readAsset(assetKey, mspIdEvidenceCustodian);

        // Read the public details by evidencecustodian.
        await contractWrapperEvidenceCustodian.readAsset(assetKey, mspIdEvidenceCustodian);

    } finally {
        gatewayCollectingOfficer.close();
        gatewayEvidenceCustodian.close();
        clientCollectingOfficer.close();
        clientEvidenceCustodian.close();
    }
}

main().catch((error: unknown) => {
    console.error('******** FAILED to run the application:', error);
    process.exitCode = 1;
});
