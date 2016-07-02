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

# Install JRE
ENV APP_JAVA_VERSION=8 APP_JAVA_UPDATE=91 APP_JAVA_BUILD=14 JAVA_HOME=/usr/lib/java
ENV PATH=$PATH:${JAVA_HOME}/bin
ENV JRE_URL="http://download.oracle.com/otn-pub/java/jdk/${APP_JAVA_VERSION}u${APP_JAVA_UPDATE}-b${APP_JAVA_BUILD}/jre-${APP_JAVA_VERSION}u${APP_JAVA_UPDATE}-linux-x64.tar.gz"
RUN wget --quiet \
         --no-cookies \
         --no-check-certificate \
         --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
         -O /tmp/jre.tgz $JRE_URL && \
    tar xzf /tmp/jre.tgz -C /tmp && \
    rm /tmp/jre.tgz && \
    mv /tmp/jre1* $JAVA_HOME && \
    update-alternatives --install "/usr/bin/java" "java" "${JAVA_HOME}/bin/java" 9999 && \
    update-alternatives --install "/usr/bin/javaws" "javaws" "${JAVA_HOME}/bin/javaws" 9999 && \
    chmod a+x /usr/bin/java /usr/bin/javaws

# Install CASSANDRA
ENV CASSANDRA_VERSION 3.7
ENV CASSANDRA_URL http://archive.apache.org/dist/cassandra/$CASSANDRA_VERSION/apache-cassandra-$CASSANDRA_VERSION-bin.tar.gz
ENV PATH=$PATH:/app/bin
RUN wget -q $CASSANDRA_URL -O /tmp/apache-cassandra.tgz && \
    cd /tmp/ && tar xzf apache-cassandra.tgz && \
    mv apache-cassandra-* /app && \
    rm -f /tmp/*.tgz 

# Configure CASSANDRA
ADD cassandra.yaml /app/config/
EXPOSE 9160 9042

COPY entrypoint.sh /bin/entrypoint.sh
CMD /bin/bash /bin/entrypoint.sh
