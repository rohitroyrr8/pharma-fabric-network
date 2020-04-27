#!/bin/bash

setRunTimeLanguage() {
    
    echo $'\n'""$'\n'
    echo $'\n'"Info: Setting CC_RUNTIME_LANGUAGE!"$'\n'
    
    if ! CC_RUNTIME_LANGUAGE=node; then
        echo $'\n'"Failure: Failed to set CC_RUNTIME_LANGUAGE!"$'\n'
        exit 1
    fi
}

setChaincodePath() {

    echo $'\n'""$'\n'
    echo $'\n'"Info: Setting CC_SRC_PATH!"$'\n'

    if ! CC_SRC_PATH=/opt/gopath/src/github.com/pharma-smart-contract; then
        echo $'\n'"Failure: Failed to set CC_SRC_PATH!"$'\n'
        exit 1
    fi
}

setPeerEnvironment() {

    echo $'\n'""$'\n'
    echo $'\n'"Info: Setting CORE_PEER_ADDRESS for $1 !"$'\n'

    if ! CORE_PEER_ADDRESS=$1.$2.trueclaim.com:7051; then
        echo $'\n'"Failure: Failed to set CORE_PEER_ADDRESS!"$'\n'
        exit 1
    fi


    echo $'\n'""$'\n'
    echo $'\n'"Info: Setting CORE_PEER_TLS_ROOTCERT_FILE for $1 !"$'\n'

    if ! CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$2.trueclaim.com/peers/$1.$2.trueclaim.com/tls/ca.crt; then
        echo $'\n'"Failure: Failed to set CORE_PEER_TLS_ROOTCERT_FILE!"$'\n'
        exit 1
    fi
}

installChaincode() {
    
    echo $'\n'""$'\n'
    echo $'\n'"Info: Installing chaincode !"$'\n'

    if ! peer chaincode install -n pharma-smartcontract -v $1 -p $CC_SRC_PATH -l $CC_RUNTIME_LANGUAGE; then
        echo $'\n'"Failure: Failed installing chaincode!"$'\n'
        exit 1 
    fi
}

instantiateChaincode() {

    echo $'\n'""$'\n'
    echo $'\n'"Info: Instantiating chaincode !"$'\n'

    if ! peer chaincode instantiate -o orderer.trueclaim.com:7050 -C claimschannel --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/trueclaim.com/orderers/orderer.trueclaim.com/msp/tlscacerts/tlsca.trueclaim.com-cert.pem -n pharma-smartcontract -l node -v $1 -c '{"Args":[]}' -P "OR ('AllParticipantsMSP.member','AllParticipantsMSP.peer', 'AllParticipantsMSP.admin', 'AllParticipantsMSP.client')" --collections-config  /opt/gopath/src/github.com/pharma-smartcontract/private_data_collection/collections_config.json; then 
        echo $'\n'"Failure: Error instantiating chaincode!"$'\n'
        exit 1 
    fi
}

if [ "$1" = "-v" ]; then	
    shift
fi
VERSION=$1;shift

setRunTimeLanguage
setChaincodePath

setPeerEnvironment peer0 allparticipants
installChaincode $VERSION

setPeerEnvironment peer1 allparticipants
installChaincode $VERSION

setPeerEnvironment peer0 allparticipants
instantiateChaincode $VERSION
