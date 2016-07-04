#!/bin/bash
set -xe


[ -z "$HOST_IP" ] && {
    echo "env var HOST_IP must be set"
    exit 1
}

function get_seeds() {
    INITIAL_CLUSTER_SIZE=3
    SEEDS=""

    while [ $(etcdctl ls /backends/cassandra/latest/ | wc -l) -lt $INITIAL_CLUSTER_SIZE]; do
        echo "Waiting for initial cluster size of $INITIAL_CLUSTER_SIZE ... "
        sleep 2
    done

    for i in $(etcdctl ls /backends/cassandra/latest/); do 
        seed=$(etcdctl get $i; done | cut -f1 -d\: dt)
        SEEDS="${SEEDS},${seed}"
    done
}

function update_config() {
    : ${CASSANDRA_RPC_ADDRESS='0.0.0.0'}

    : ${CASSANDRA_LISTEN_ADDRESS='auto'}
    if [ "$CASSANDRA_LISTEN_ADDRESS" = 'auto' ]; then
        CASSANDRA_LISTEN_ADDRESS="$(hostname --ip-address)"
    fi

    : ${CASSANDRA_BROADCAST_ADDRESS="$CASSANDRA_LISTEN_ADDRESS"}

    if [ "$CASSANDRA_BROADCAST_ADDRESS" = 'auto' ]; then
        CASSANDRA_BROADCAST_ADDRESS="$(hostname --ip-address)"
    fi
    : ${CASSANDRA_BROADCAST_RPC_ADDRESS:=$CASSANDRA_BROADCAST_ADDRESS}

    if [ -n "${CASSANDRA_NAME:+1}" ]; then
        : ${CASSANDRA_SEEDS:="cassandra"}
    fi
    : ${CASSANDRA_SEEDS:="$CASSANDRA_BROADCAST_ADDRESS"}

    sed -ri 's/(- seeds:).*/\1 "'"$CASSANDRA_SEEDS"'"/' "$CASSANDRA_CONFIG/cassandra.yaml"

    for yaml in \
        broadcast_address \
            broadcast_rpc_address \
            cluster_name \
            endpoint_snitch \
            listen_address \
            num_tokens \
            rpc_address \
            start_rpc \
    ; do
        var="CASSANDRA_${yaml^^}"
        val="${!var}"
        if [ "$val" ]; then
            sed -ri 's/^(# )?('"$yaml"':).*/\2 '"$val"'/' "$CASSANDRA_CONFIG/cassandra.yaml"
        fi
    done

    for rackdc in dc rack; do
        var="CASSANDRA_${rackdc^^}"
        val="${!var}"
        if [ "$val" ]; then
            sed -ri 's/^('"$rackdc"'=).*/\1 '"$val"'/' "$CASSANDRA_CONFIG/cassandra-rackdc.properties"
        fi
    done
}


ENV=/app/conf/cassandra-env.sh

# wait 10 seconds instead of 30
export JVM_OPTS="-Dcassandra.ring_delay_ms=10000"

# Fix JMX settings
sed -i -e 's/# JVM_OPTS="$JVM_OPTS -Djava.rmi.server.hostname=<public name>"/JVM_OPTS="$JVM_OPTS -Djava.rmi.server.hostname='$HOST_IP'"/g' $ENV

[ -z $SEEDS ] && getpeers

sed -i "s/_SEEDS_/${SEEDS}/g" /app/config/cassandra.yaml

/app/bin/cassandra -f
