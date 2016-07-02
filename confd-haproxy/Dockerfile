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
ENV version=2

ENV CONFD_VERSION 0.11.0
ENV CONFD_URL https://github.com/kelseyhightower/confd/releases/download/v$CONFD_VERSION/confd-$CONFD_VERSION-linux-amd64

RUN apt-get -yqq update && apt-get -yq install haproxy
RUN wget $CONFD_URL -O /usr/local/bin/confd && chmod +x /usr/local/bin/confd

COPY entrypoint.sh /
CMD /bin/bash /entrypoint.sh
