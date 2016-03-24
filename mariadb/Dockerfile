#
# BRICKLY.IO CONFIDENTIAL
# ______________________________
#
#  [2015] - [2016] Brickly.Io Incorporated
#  All Rights Reserved.
#
# NOTICE: All information contained herein is, and remains the property of Brickly.Io Incorporated
# and its suppliers, if any.  The intellectual and technical concepts contained herein are
# proprietary to Brickly.Io Incorporated and its suppliers and may be covered by U.S. and Foreign
# Patents, patents in process, and are protected by trade secret or copyright law. Dissemination of
# this information or reproduction of this material is strictly forbidden unless prior written
# permission is obtained from Brickly.Io Incorporated.
#

FROM i-docker.brickly.io/etcd:latest
ENV version=2

# add our user and group first to make sure their IDs get assigned consistently
# regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

ENV MARIADB_VERSION 10.0

RUN rm -rf /var/lib/apt/lists/* \
    && apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db \
    && echo "deb http://sfo1.mirrors.digitalocean.com/mariadb/repo/${MARIADB_VERSION}/debian jessie main" >> /etc/apt/sources.list \
    && echo "deb http://sfo1.mirrors.digitalocean.com/mariadb/repo/${MARIADB_VERSION}/debian sid main" >> /etc/apt/sources.list \
    && apt-get -yqq clean \
    && apt-get -yqq update \
    && apt-get install -yf iproute galera-3 mariadb-galera-server-$MARIADB_VERSION rsync netcat-openbsd socat pv
#    && echo "deb http://httpredir.debian.org/debian testing main contrib non-free" >> /etc/apt/sources.list \

RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A && \
    echo "deb http://repo.percona.com/apt jessie main" >> /etc/apt/sources.list && \
    apt-get -yqq update && \
    apt-get install -yqqf percona-xtrabackup jq dnsutils

# Add config(s) - standalone and cluster mode
ADD ./my-cluster.cnf /etc/mysql/my-cluster.cnf
ADD ./my-init.cnf /etc/mysql/my-init.cnf
ADD ./mariadb-setrootpassword.sh /usr/bin/mariadb-setrootpassword
ADD ./mariadb-start.sh /usr/bin/mariadb-start
RUN chmod a+x /usr/bin/mariadb-start /usr/bin/mariadb-setrootpassword

expose	3306 4567 4444

VOLUME /var/lib/mysql

ENTRYPOINT ["/usr/bin/mariadb-start"]
