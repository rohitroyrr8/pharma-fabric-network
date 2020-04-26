network_orgs=(allparticipants)

function copyCACerts() {

    echo $'\n'"******************* Copying CA certificates for $1 *******************"$'\n'

    awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/$1.trueclaim.com/peers/peer0.$1.trueclaim.com/tls/ca.crt > network-connections/$1/ca-$1.txt

    echo
    sleep 5
}

function copyCertsForOrdererCA() {

    echo $'\n'"******************* Copying CA certificates for orderer *******************"$'\n'

    awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/ordererOrganizations/trueclaim.com/orderers/orderer.trueclaim.com/tls/ca.crt > network-connections/ca-orderer.txt

    echo
    sleep 5
}

function copyCertsForFabricAdmin() {

    echo $'\n'"******************* Copying Fabric Admin certificates for $1 *******************"$'\n'

    export ORG_MSP_PATH=crypto-config/peerOrganizations/$1.trueclaim.com/users/Admin@$1.trueclaim.com/msp
    rm -rf ./docker-builds/$1/machine1/composer/$1/*.pem
    rm -rf ./docker-builds/$1/machine1/composer/$1/*_sk
    cp -p $ORG_MSP_PATH/signcerts/A*.pem ./docker-builds/$1/machine1/composer/$1/
    cp -p $ORG_MSP_PATH/keystore/*_sk ./docker-builds/$1/machine1/composer/$1/
    
    echo
    sleep 5
}

echo "#####################################################################################"
echo "################### Copying CA certificates for network orgs ########################"
echo "#####################################################################################"

for i in "${network_orgs[@]}"
do
    copyCACerts $i
done

echo "#####################################################################################"
echo "################### Copying CA certificates for Orderer Org #########################"
echo "#####################################################################################"

copyCertsForOrdererCA
echo
