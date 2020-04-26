network_orgs=(AllParticipants)

function generateCerts() {
    if [ -d "crypto-config" ]; then
        rm -Rf crypto-config
    fi

    set -x
    cryptogen generate --config=./network-setup/crypto-config.yaml
    res=$?

    set +x

    if [ $res -ne 0 ]; then
        echo "Failed to generate certificates..."
        exit 1
    fi

    echo
    echo
}

function copyOrgCerts() {

    echo $'\n'"******************* Copying $1 certificates *******************"$'\n'

    if [ "$1" = "allparticipants" ]; then

        echo $'\n'"Removing old orderer certificates..."$'\n'
        rm -rf ./docker-builds/$1/machine1/crypto-config/ordererOrganizations
        echo $'\n'"Removed successfully!"$'\n'

        if [ ! -d ./docker-builds/$1/machine1/crypto-config/ordererOrganizations ]; then
            mkdir -p docker-builds/$1/machine1/crypto-config/ordererOrganizations
        fi

        echo $'\n'"Copying new orderer certificates..."$'\n'
        cp -r ./crypto-config/ordererOrganizations ./docker-builds/$1/machine1/crypto-config/
        echo $'\n'"Copied successfully!"$'\n'
    fi


    echo $'\n'"Removing old peer certificates..."$'\n'
    rm -rf ./docker-builds/$1/machine1/crypto-config/peerOrganizations/*
    echo $'\n'"Removed successfully!"$'\n'
    
    if [ ! -d ./docker-builds/$1/machine1/crypto-config/peerOrganizations ]; then
        mkdir -p docker-builds/$1/machine1/crypto-config/peerOrganizations
    fi

    echo $'\n'"Copying new peer certificates..."$'\n'
    cp -r ./crypto-config/peerOrganizations/$1.trueclaim.com ./docker-builds/$1/machine1/crypto-config/peerOrganizations/
    echo $'\n'"Copied successfully!"$'\n'
    

    echo $'\n'"Removing old genesis and channel configuration..."$'\n'
    rm -rf ./docker-builds/$1/machine1/channel-artifacts
    echo $'\n'"Removed successfully!"$'\n'
    
    if [ ! -d ./docker-builds/$1/machine1/channel-artifacts ]; then
        mkdir -p docker-builds/$1/machine1/channel-artifacts
    fi

    echo $'\n'"Copying new genesis and channel configuration..."$'\n'
    cp -r ./channel-artifacts/* ./docker-builds/$1/machine1/channel-artifacts/
    rm -rf ./crypto-config
    rm -rf ./channel-artifacts
    echo $'\n'"Copied successfully!"$'\n'

}

function generateGenesisBlock() {

    echo $'\n'"##### Removing old genesis block #########"$'\n'
    rm -rf ./channel-artifacts/*

    if [ ! -d ./channel-artifacts ]; then
        mkdir channel-artifacts
    fi

    echo $'\n'"##### Generating new genesis block #########"$'\n'    
    export FABRIC_CFG_PATH=${PWD}/setup-transactions/
    export CHANNEL_NAME=claimschannel
    configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block -channelID $CHANNEL_NAME
    echo $'\n'"######## Genesis block created successfully ###########"$'\n'

}

function createChannel() {

    echo "##########################################################"
    echo "############ Generating channel transaction ##############"
    echo "##########################################################"

    export CHANNEL_NAME=claimschannel

    configtxgen -profile ChannelGenesis -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

    echo
    echo "######## Channel created successfully ###########"
}

function createAnchorPeerTransactions() {
    
    echo $'\n'"******************* Anchor Transaction for $1 *******************"$'\n'

    configtxgen -profile ChannelGenesis -outputAnchorPeersUpdate ./channel-artifacts/$1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg $1

}

echo "##########################################################"
echo "##### Generate certificates using cryptogen tool #########"
echo "##########################################################"

generateCerts


echo
echo
echo

echo "##########################################################"
echo "##### Generating genesis block using configtxgen tool ####"
echo "##########################################################"

echo
echo
generateGenesisBlock

echo "##########################################################"
echo "# Generating channel transaction using configtxgen tool  #"
echo "##########################################################"

echo
echo
createChannel

echo "##########################################################"
echo "# Generating anchor transactions using configtxgen tool  #"
echo "##########################################################"

for i in ${network_orgs[@]}
do
    createAnchorPeerTransactions ${i,,}
done

echo "#####################################################################################"
echo "##### Copying certificates and channel configurations for network orgs ##############"
echo "#####################################################################################"

for i in "${network_orgs[@]}"
do
    copyOrgCerts ${i,,}
done



