#!/bin/bash
set -e

status () {
    echo "---> ${@}" >&2
}

get_node_addr() {
    if [ -z ${NODE_ADDR+x} ]; then
        echo $(ip -4 addr show eth0 | grep inet | sed -e 's/  */ /g' | cut -d ' ' -f 3 | cut -d '/' -f 1)
    else
        echo ${NODE_ADDR}
    fi
}

ln -sf /var/lib/mysql/mysql.sock /var/run/mysqld/mysqld.sock

sed -i "s|^port.*=.*$|port = ${HOST_PORT}|" /etc/mysql/my-init.cnf
ln -sf /etc/mysql/my-init.cnf /etc/mysql/my.cnf

if [ ! -e /var/lib/mysql/bootstrapped ] && [ ! -e /var/lib/mysql/xtrabackup_info ]; then
    status "Bootstrapping MariaDB installation..."

    status "Initializing MariaDB root directory at /var/lib/mysql"
    mysql_install_db

    status "Setting MariaDB root password"
    /usr/bin/mariadb-setrootpassword
    touch /var/lib/mysql/bootstrapped
else
    status "Starting from already-bootstrapped MariaDB installation"
fi

sed -i "s|^port.*=.*$|port = ${HOST_PORT}|" /etc/mysql/my-cluster.cnf
ln -sf /etc/mysql/my-cluster.cnf /etc/mysql/my.cnf

sed -i 's|encrypt=$(parse_cnf sst encrypt 0)|encrypt=0|' /usr/bin/wsrep_sst_xtrabackup-v2

if [ ! -z ${CLUSTER_PEERS+x} ]; then
    peers=${CLUSTER_PEERS}
    status "Using cluster peers defined in env: $CLUSTER_PEERS"
else
    peers=""
    status "This node: $(get_node_addr)"
    sleep 600

    for backend in $(etcdctl ls --recursive /backends/mariadb/latest/);do
	peer=$(etcdctl get ${backend} | sed 's/:3306//g;s/\ //g')
	[ "$peer" != "$(get_node_addr)" ] && {
	    peers="${peers},${peer}"
	}
    done

    #format peers list
    peers=$(echo $peers | sed 's/\ //g;s/^,//g')

    status "Using discovered peers: ${peers}"
fi

if [ -z ${peers} ]; then
    # initialize the initial cluster node
    status "No peers found, initializing new cluster"
    exec /usr/bin/mysqld_safe --wsrep_node_address="$(get_node_addr)" \
         --wsrep_node_incoming_address="$(get_node_addr)" \
         --wsrep_new_cluster --wsrep_cluster_address="gcomm://" \
         --log-error=/var/lib/mysql/mysql.error.log
else
  # cluster joiner node
    exec /usr/bin/mysqld_safe --wsrep_node_address="$(get_node_addr)" \
         --wsrep_node_incoming_address="$(get_node_addr)" \
	 --wsrep_cluster_address="gcomm://${peers}" \
         --log-error=/var/lib/mysql/mysql.error.log
fi
