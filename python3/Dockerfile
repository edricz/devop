#
# INME TECHNOLOGIES CONFIDENTIAL
# ______________________________
#
#  [2015] - [2016] Inme Technologies Incorporated
#  All Rights Reserved.
#
# NOTICE: All information contained herein is, and remains the property of Inme Technologies
# Incorporated and its suppliers, if any.  The intellectual and technical concepts contained herein
# are proprietary to Inme Technologies Incorporated and its suppliers and may be covered by
# U.S. and Foreign Patents, patents in process, and are protected by trade secret or copyright
# law. Dissemination of this information or reproduction of this material is strictly forbidden
# unless prior written permission is obtained from Inme Technologies Incorporated.
#

FROM i-docker.inme.io/base:latest

RUN apt-get install -yqq --force-yes --no-install-recommends \
      curl build-essential zlib1g-dev libbz2-dev liblzma-dev libssl-dev ca-certificates

ENV PYTHON3_VERSION 3.5.0
RUN curl -ksSL -o python3.tgz https://www.python.org/ftp/python/$PYTHON3_VERSION/Python-$PYTHON3_VERSION.tgz \
    && mkdir /python3 \
    && tar -xzf python3.tgz -C /python3 --strip-components=1 \
    && rm python3.tgz \
    && cd /python3 \
    && ./configure --enable-shared \
    && make \
    && make install \
    && ldconfig \
    && cd / \
    && rm -rf /python3
