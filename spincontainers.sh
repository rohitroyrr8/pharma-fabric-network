function spinContainers() {
 
    echo $'\n'"Spinning "$1" peer and couchdb containers..."$'\n'

    if ! docker-compose -f build_containers.yaml -f setup_couchdb.yaml $1; then
        echo $'\n'"Failure: Failed creating containers!"$'\n'
        exit 1
    fi
}

if [ "$1" = "-m" ]; then	
    shift
fi
MODE=$1;shift

spinContainers $MODE
