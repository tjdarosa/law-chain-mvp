export FABRIC_CFG_PATH=$(pwd)/config
cd ../fabric-samples/
export PATH=$PATH:$(pwd)/bin
cd ../law-chain-mvp-project

cryptogen \
    generate \
    --config=./config/crypto-config.yaml \
    --output=./organizations

configtxgen \
    -profile LawSystemGenesis \
    -channelID system-channel \
    -outputBlock ./channel-artifacts/genesis.block

configtxgen \
    -profile LawChannel \
    -outputCreateChannelTx ./channel-artifacts/lawchannel.tx \
    -channelID lawchannel

# Collecting Officer
configtxgen \
    -profile LawChannel \
    -outputAnchorPeersUpdate ./channel-artifacts/CollectingOfficerOrgAnchors.tx \
    -channelID lawchannel \
    -asOrg CollectingOfficerOrgMSP

# Evidence Custodian
configtxgen \
    -profile LawChannel \
    -outputAnchorPeersUpdate ./channel-artifacts/EvidenceCustodianOrgAnchors.tx \
    -channelID lawchannel \
    -asOrg EvidenceCustodianOrgMSP

# Forensic Analyst
configtxgen \
    -profile LawChannel \
    -outputAnchorPeersUpdate ./channel-artifacts/ForensicAnalystOrgAnchors.tx \
    -channelID lawchannel \
    -asOrg ForensicAnalystOrgMSP

# Prosecutor
configtxgen \
    -profile LawChannel \
    -outputAnchorPeersUpdate ./channel-artifacts/ProsecutorOrgAnchors.tx \
    -channelID lawchannel \
    -asOrg ProsecutorOrgMSP

# Courtroom Personnel does not have a .tx because it does not propose transactions

