package main

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type SmartContract struct {
	contractapi.Contract
}

type Evidence struct {
	ID          string `json:"id"`
	Hash        string `json:"hash"`
	Timestamp   string `json:"timestamp"`
	Owner       string `json:"owner"`
	Description string `json:"description"`
	FileName    string `json:"fileName"`
	Signature   string `json:"signature"`
	PublicKey   string `json:"publicKey"`
}

// Store new evidence
func (s *SmartContract) StoreEvidence(ctx contractapi.TransactionContextInterface, id string, hash string, owner string, description string, fileName string, signature string, publicKey string) error {
	evidence := Evidence{
		ID:          id,
		Hash:        hash,
		Timestamp:   time.Now().Format(time.RFC3339),
		Owner:       owner,
		Description: description,
		FileName:    fileName,
		Signature:   signature,
		PublicKey:   publicKey,
	}

	evidenceBytes, err := json.Marshal(evidence)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(id, evidenceBytes)
}

// Read existing evidence
func (s *SmartContract) ReadEvidence(ctx contractapi.TransactionContextInterface, id string) (*Evidence, error) {
	data, err := ctx.GetStub().GetState(id)
	if err != nil || data == nil {
		return nil, fmt.Errorf("evidence %s not found", id)
	}

	var evidence Evidence
	err = json.Unmarshal(data, &evidence)
	if err != nil {
		return nil, err
	}

	return &evidence, nil
}

func main() {
	chaincode, err := contractapi.NewChaincode(&SmartContract{})
	if err != nil {
		panic("Error creating lawchain smart contract: " + err.Error())
	}

	if err := chaincode.Start(); err != nil {
		panic("Error starting lawchain smart contract: " + err.Error())
	}
}

