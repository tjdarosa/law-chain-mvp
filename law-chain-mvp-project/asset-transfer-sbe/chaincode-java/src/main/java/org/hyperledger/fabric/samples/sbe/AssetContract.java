/*
 * SPDX-License-Identifier: Apache-2.0
 */

package org.hyperledger.fabric.samples.sbe;

import com.owlike.genson.Genson;
import org.hyperledger.fabric.contract.Context;
import org.hyperledger.fabric.contract.ContractInterface;
import org.hyperledger.fabric.contract.annotation.Contract;
import org.hyperledger.fabric.contract.annotation.Default;
import org.hyperledger.fabric.contract.annotation.Info;
import org.hyperledger.fabric.contract.annotation.License;
import org.hyperledger.fabric.contract.annotation.Transaction;
import org.hyperledger.fabric.protos.common.MSPPrincipal;
import org.hyperledger.fabric.protos.common.MSPRole;
import org.hyperledger.fabric.protos.common.SignaturePolicy;
import org.hyperledger.fabric.protos.common.SignaturePolicyEnvelope;
import org.hyperledger.fabric.shim.ChaincodeException;
import org.hyperledger.fabric.shim.ChaincodeStub;
import org.hyperledger.fabric.shim.ext.sbe.StateBasedEndorsement;
import org.hyperledger.fabric.shim.ext.sbe.impl.StateBasedEndorsementFactory;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Contract(
        name = "sbe",
        info = @Info(
                title = "Asset Contract",
                description = "Asset Transfer Smart Contract, using State Based Endorsement(SBE), implemented in Java",
                version = "0.0.1-SNAPSHOT",
                license = @License(
                        name = "Apache 2.0 License",
                        url = "http://www.apache.org/licenses/LICENSE-2.0.html")))
@Default
public final class AssetContract implements ContractInterface {
    private final Genson genson = new Genson();

    private enum AssetTransferErrors {
        ASSET_NOT_FOUND,
        ASSET_ALREADY_EXISTS
    }

    /**
     * Creates a new asset.
     * Sets the endorsement policy of the assetId Key, such that current owner Org Peer is required to endorse future updates.
     * Optionally, set the endorsement policy of the assetId Key, such that any 1(N) out of the Org's specified can endorse future updates.
     *
     * @param ctx the transaction context
     * @param assetId the id of the new asset
     * @param value the value of the new asset
     * @param owner the owner of the new asset
     * @return the created asset
     */
    @Transaction(intent = Transaction.TYPE.SUBMIT)
    public Asset CreateAsset(final Context ctx, final String assetId, final int value, final String owner) {
        ChaincodeStub stub = ctx.getStub();

        if (AssetExists(ctx, assetId)) {
            String errorMessage = String.format("Asset %s already exists", assetId);
            System.out.println(errorMessage);
            throw new ChaincodeException(errorMessage, AssetTransferErrors.ASSET_ALREADY_EXISTS.toString());
        }

        final String ownerOrg = getClientOrgId(ctx);
        Asset asset = new Asset(assetId, value, owner, ownerOrg);
        String assetJSON = genson.serialize(asset);
        stub.putStringState(assetId, assetJSON);

        // Set the endorsement policy of the assetId Key, such that current owner Org is required to endorse future updates
        setStateBasedEndorsement(ctx, assetId, List.of(ownerOrg));

        // Optionally, set the endorsement policy of the assetId Key, such that any 1 Org (N) out of the specified Orgs can endorse future updates
        // setStateBasedEndorsementNOutOf(ctx, assetId, 1, new String[]{"CollectingOfficerMSP", "EvidenceCustodianMSP"});

        return asset;
    }

    /**
     * Retrieves an asset with the given assetId.
     *
     * @param ctx the transaction context
     * @param assetId the id of the asset
     * @return the asset found on the ledger if there was one
     */
    @Transaction(intent = Transaction.TYPE.EVALUATE)
    public String ReadAsset(final Context ctx, final String assetId) {
        ChaincodeStub stub = ctx.getStub();
        String assetJSON = stub.getStringState(assetId);

        if (assetJSON == null || assetJSON.isEmpty()) {
            String errorMessage = String.format("Asset %s does not exist", assetId);
            System.out.println(errorMessage);
            throw new ChaincodeException(errorMessage, AssetTransferErrors.ASSET_NOT_FOUND.toString());
        }

        return assetJSON;
    }

    /**
     * Updates the properties of an existing asset.
     * Needs an endorsement of current owner Org Peer.
     *
     * @param ctx the transaction context
     * @param assetId the id of the asset being updated
     * @param newValue the value of the asset being updated
     * @return the updated asset
     */
    @Transaction(intent = Transaction.TYPE.SUBMIT)
    public Asset UpdateAsset(final Context ctx, final String assetId, final int newValue) {
        ChaincodeStub stub = ctx.getStub();

        String assetString = ReadAsset(ctx, assetId);
        Asset asset = genson.deserialize(assetString, Asset.class);
        asset.setValue(newValue);
        String updatedAssetJSON = genson.serialize(asset);
        stub.putStringState(assetId, updatedAssetJSON);

        return asset;
    }

    /**
     * Deletes the given asset.
     * Needs an endorsement of current owner Org Peer.
     *
     * @param ctx the transaction context
     * @param assetId the id of the asset being deleted
     */
    @Transaction(intent = Transaction.TYPE.SUBMIT)
    public void DeleteAsset(final Context ctx, final String assetId) {
        ChaincodeStub stub = ctx.getStub();

        if (!AssetExists(ctx, assetId)) {
            String errorMessage = String.format("Asset %s does not exist", assetId);
            System.out.println(errorMessage);
            throw new ChaincodeException(errorMessage, AssetTransferErrors.ASSET_NOT_FOUND.toString());
        }

        stub.delState(assetId);
    }

    /**
     * Updates the owner & ownerOrg field of asset with given assetId, ownerOrg must be a valid Org MSP Id.
     * Needs an endorsement of current owner Org Peer.
     * Re-sets the endorsement policy of the assetId Key, such that new owner Org Peer is required to endorse future updates.
     *
     * @param ctx the transaction context
     * @param assetId the id of the asset being transferred
     * @param newOwner the new owner
     * @param newOwnerOrg the new owner Org MSPID
     * @return the updated asset
     */
    @Transaction(intent = Transaction.TYPE.SUBMIT)
    public Asset TransferAsset(final Context ctx, final String assetId, final String newOwner, final String newOwnerOrg) {
        ChaincodeStub stub = ctx.getStub();

        String assetString = ReadAsset(ctx, assetId);
        Asset asset = genson.deserialize(assetString, Asset.class);
        asset.setOwner(newOwner);
        asset.setOwnerOrg(newOwnerOrg);
        String updatedAssetJSON = genson.serialize(asset);
        stub.putStringState(assetId, updatedAssetJSON);

        // Re-Set the endorsement policy of the assetId Key, such that a new owner Org Peer is required to endorse future updates
        setStateBasedEndorsement(ctx, assetId, List.of(newOwnerOrg));

        // Optionally, set the endorsement policy of the assetId Key, such that any 1 Org (N) out of the specified Orgs can endorse future updates
        // setStateBasedEndorsementNOutOf(ctx, assetId, 1, List.of("CollectingOfficerMSP", "EvidenceCustodianMSP"));

        return asset;
    }

    /**
     * Checks the existence of the asset.
     *
     * @param ctx the transaction context
     * @param assetId the id of the asset
     * @return boolean indicating the existence of the asset
     */
    private boolean AssetExists(final Context ctx, final String assetId) {
        ChaincodeStub stub = ctx.getStub();
        String assetJSON = stub.getStringState(assetId);

        return (assetJSON != null && !assetJSON.isEmpty());
    }

    /**
     * Retrieves the client's OrgId (MSPID)
     *
     * @param ctx the transaction context
     * @return String value of the Org MSPID
     */
    private static String getClientOrgId(final Context ctx) {
        return ctx.getClientIdentity().getMSPID();
    }

    /**
     * Sets an endorsement policy to the assetId Key.
     * Enforces that the owner Org must endorse future update transactions for the specified assetId Key.
     *
     * @param ctx the transaction context
     * @param assetId the id of the asset
     * @param ownerOrgs the list of Owner Org MSPID's
     */
    private static void setStateBasedEndorsement(final Context ctx, final String assetId, final List<String> ownerOrgs) {
        StateBasedEndorsement stateBasedEndorsement = StateBasedEndorsementFactory.getInstance().newStateBasedEndorsement(null);
        stateBasedEndorsement.addOrgs(StateBasedEndorsement.RoleType.RoleTypeMember, ownerOrgs.toArray(new String[0]));
        ctx.getStub().setStateValidationParameter(assetId, stateBasedEndorsement.policy());
    }

    /**
     * Sets an endorsement policy to the assetId Key.
     * Enforces that a given number of Orgs (N) out of the specified Orgs must endorse future update transactions for the specified assetId Key.
     *
     * @param ctx the transaction context
     * @param assetId the id of the asset
     * @param nOrgs the number of N Orgs to endorse out of the list of Orgs provided
     * @param ownerOrgs the list of Owner Org MSPID's
     */
    private static void setStateBasedEndorsementNOutOf(final Context ctx, final String assetId, final int nOrgs, final List<String> ownerOrgs) {
        ctx.getStub().setStateValidationParameter(assetId, policy(nOrgs, ownerOrgs));
    }

    /**
     * Create a policy that requires a given number (N) of Org principals signatures out of the provided list of Orgs
     *
     * @param nOrgs the number of Org principals signatures required to endorse (out of the provided list of Orgs)
     * @param mspIds the list of Owner Org MSPID's
     */
    private static byte[] policy(final int nOrgs, final List<String> mspIds) {
        mspIds.sort(Comparator.naturalOrder());

        var principals = mspIds.stream()
                .map(mspId -> MSPRole.newBuilder()
                        .setMspIdentifier(mspId)
                        .setRole(MSPRole.MSPRoleType.MEMBER)
                        .build())
                .map(role -> MSPPrincipal.newBuilder()
                        .setPrincipalClassification(MSPPrincipal.Classification.ROLE)
                        .setPrincipal(role.toByteString())
                        .build())
                .collect(Collectors.toList());

        var signPolicy = IntStream.range(0, mspIds.size())
                .mapToObj(AssetContract::signedBy)
                .collect(Collectors.toList());

        // Create the policy such that it requires any N signature's from all the principals provided
        return SignaturePolicyEnvelope.newBuilder()
                .setVersion(0)
                .setRule(nOutOf(nOrgs, signPolicy))
                .addAllIdentities(principals)
                .build()
                .toByteArray();
    }

    private static SignaturePolicy signedBy(final int index) {
        return SignaturePolicy.newBuilder().setSignedBy(index).build();
    }

    private static SignaturePolicy nOutOf(final int n, final List<SignaturePolicy> policies) {
        return SignaturePolicy.newBuilder().setNOutOf(
                SignaturePolicy.NOutOf.newBuilder().setN(n).addAllRules(policies).build()
        ).build();
    }
}
