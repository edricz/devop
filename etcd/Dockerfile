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

FROM i-docker.brickly.io/base:latest

ENV VERSION v2.2.5
ENV URL https://github.com/coreos/etcd/releases/download/$VERSION/etcd-$VERSION-linux-amd64.tar.gz

RUN curl -L $URL -o /tmp/etcd.tar.gz && \
    cd /tmp && tar zxf etcd.tar.gz && \
    mv -v etcd-*/etcd /usr/local/bin/ && \
    mv -v etcd-*/etcdctl /usr/local/bin/

VOLUME /app/data
ADD etcd.sh /bin/etcd.sh
ADD etcd_monitor.sh /bin/etcd_monitor.sh

ENTRYPOINT ["/bin/etcd.sh"]
