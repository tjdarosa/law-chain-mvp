/*
Copyright 2020 IBM All Rights Reserved.

SPDX-License-Identifier: Apache-2.0
*/

package functions

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/hyperledger/fabric-sdk-go/pkg/core/config"
	"github.com/hyperledger/fabric-sdk-go/pkg/gateway"
)

// Query can be used to read the latest value of a variable
func Query(function, variableName string) ([]byte, error) {

	err := os.Setenv("DISCOVERY_AS_LOCALHOST", "true")
	if err != nil {
		return nil, fmt.Errorf("error setting DISCOVERY_AS_LOCALHOST environemnt variable: %v", err)
	}

	wallet, err := gateway.NewFileSystemWallet("wallet")
	if err != nil {
		return nil, fmt.Errorf("failed to create wallet: %v", err)
	}

	if !wallet.Exists("appUser") {
		err = populateWallet(wallet)
		if err != nil {
			return nil, fmt.Errorf("failed to populate wallet contents: %v", err)
		}
	}

	ccpPath := filepath.Join(
		"..",
		"..",
		"test-network",
		"organizations",
		"peerOrganizations",
		"collectingofficer.example.com",
		"connection-collectingofficer.yaml",
	)

	gw, err := gateway.Connect(
		gateway.WithConfig(config.FromFile(filepath.Clean(ccpPath))),
		gateway.WithIdentity(wallet, "appUser"),
	)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to gateway: %v", err)
	}
	defer gw.Close()

	network, err := gw.GetNetwork("mychannel")
	if err != nil {
		return nil, fmt.Errorf("failed to get network: %v", err)
	}

	contract := network.GetContract("bigdatacc")

	result, err := contract.EvaluateTransaction(function, variableName)
	if err != nil {
		return nil, fmt.Errorf("failed to evaluate transaction: %v", err)
	}
	return result, err
}
