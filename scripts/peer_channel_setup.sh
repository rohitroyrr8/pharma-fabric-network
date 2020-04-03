network_orgs=(AllParticipants)

function setChannelName() {

    echo $'\n'"Setting channel name..."$'\n'

    if export CHANNEL_NAME=$1; then
        echo $'\n'"Success: Channel name set to "$1"."$'\n'
    else
        echo $'\n'"Failure: Failed to set the channel name!"$'\n'
        exit 1
    fi
}

function setPeerEnvironmentVariables() {

    echo $'\n'"Setting environment variables for "$1 "of" $2"..."$'\n'

    if ! CORE_PEER_TLS_ENABLED=true; then
        echo $'\n'"Failure: Failed to set CORE_PEER_TLS_ENABLED!"$'\n'
        exit 1
    fi

    if ! CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$2.pharma-network.com/users/Admin@$2.pharma-network.com/msp; then
        echo $'\n'"Failure: Failed to set CORE_PEER_MSPCONFIGPATH!"$'\n'
        exit 1
    fi

    if ! CORE_PEER_ADDRESS=$1.$2.pharma-network.com:7051; then
        echo $'\n'"Failure: Failed to set CORE_PEER_ADDRESS!"$'\n'
        exit 1
    fi

    if ! CORE_PEER_LOCALMSPID=$3; then
        echo $'\n'"Failure: Failed to set CORE_PEER_LOCALMSPID!"$'\n'
        exit 1
    fi


    if ! CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$2.pharma-network.com/peers/$1.$2.pharma-network.com/tls/ca.crt; then
        echo $'\n'"Failure: Failed to set CORE_PEER_TLS_ROOTCERT_FILE!"$'\n'
        exit 1
    fi

    if ! CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$2.pharma-network.com/peers/$1.$2.pharma-network.com/tls/server.crt; then
        echo $'\n'"Failure: Failed to set CORE_PEER_TLS_CERT_FILE!"$'\n'
        exit 1
    fi

    if ! CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$2.pharma-network.com/peers/$1.$2.pharma-network.com/tls/server.key; then
        echo $'\n'"Failure: Failed to set CORE_PEER_TLS_KEY_FILE!"$'\n'
        exit 1
    fi

    echo $'\n'"Success: Environment variables set for "$1 "of" $2"!"$'\n'
}

function createChannel() {
    
    echo $'\n'"Creating channel..."$'\n'
    
    if peer channel create -o orderer.pharma-network.com:7050 -c $CHANNEL_NAME -f ../channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/pharma-network.com/orderers/orderer.pharma-network.com/msp/tlscacerts/tlsca.pharma-network.com-cert.pem; then
        echo $'\n'"Success: Channel created."$'\n'
        echo $'\n'"Sleeping for 30 seconds...."$'\n'
        sleep 30
    else
        echo $'\n'"Failure: Failed to create channel!"$'\n'
        exit 1
    fi
    
}

function joinChannel() {
    
    echo $'\n'"Joining channel..."$'\n'

    if peer channel join -b pharmachannel.block; then
        echo $'\n'"Success: Channel joined."$'\n'
        echo $'\n'"Sleeping for 30 seconds...."$'\n'
        sleep 30
    else
        echo $'\n'"Failure: Failed to join channel!"$'\n'
        exit 1
    fi
}

function updateMSPAnchors() {

    echo $'\n'"Updating MSP Anchors..."$'\n'

    if ! peer channel update -o orderer.pharma-network.com:7050 -c $CHANNEL_NAME -f ../channel-artifacts/$1anchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/pharma-network.com/orderers/orderer.pharma-network.com/msp/tlscacerts/tlsca.pharma-network.com-cert.pem; then
        echo $'\n'"Failure: Failed to update MSP Anchor!"$'\n'
        exit 1
    else
        echo $'\n'"Success: MSP Anchor updated."$'\n'
        echo $'\n'"Sleeping for 30 seconds...."$'\n'
        sleep 30
    fi
}

#1. Setting channel name
setChannelName pharmachannel

#2. Set environment variables for each of the peer and join the channel

for i in ${network_orgs[@]}
do
    for n in 0 1
    do
        setPeerEnvironmentVariables peer$n ${i,,} $i"MSP"
        if [ "$i" = "AllParticipants" ] && [ $n == 0 ]; then
            createChannel
        fi
        joinChannel
    done
done

#3. Update MSPs using transactions

for i in ${network_orgs[@]}
do
    setPeerEnvironmentVariables peer0 ${i,,} $i"MSP"
    updateMSPAnchors $i"MSP"
done