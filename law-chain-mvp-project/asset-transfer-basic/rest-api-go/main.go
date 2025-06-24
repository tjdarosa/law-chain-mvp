package main

import (
	"fmt"
	"rest-api-go/web"
)

func main() {
	//Initialize setup for CollectingOfficer
	cryptoPath := "../../test-network/organizations/peerOrganizations/collectingofficer.example.com"
	orgConfig := web.OrgSetup{
		OrgName:      "CollectingOfficer",
		MSPID:        "CollectingOfficerMSP",
		CertPath:     cryptoPath + "/users/User1@collectingofficer.example.com/msp/signcerts/cert.pem",
		KeyPath:      cryptoPath + "/users/User1@collectingofficer.example.com/msp/keystore/",
		TLSCertPath:  cryptoPath + "/peers/peer0.collectingofficer.example.com/tls/ca.crt",
		PeerEndpoint: "dns:///localhost:7051",
		GatewayPeer:  "peer0.collectingofficer.example.com",
	}

	orgSetup, err := web.Initialize(orgConfig)
	if err != nil {
		fmt.Println("Error initializing setup for CollectingOfficer: ", err)
	}
	web.Serve(web.OrgSetup(*orgSetup))
}
