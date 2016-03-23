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

FROM i-docker.brickly.io/python3:latest

# Download and install sqlite
ENV SQLITE_VERSION 3110100
RUN curl -ksSL -o sqlite.tgz http://www.sqlite.org/2016/sqlite-autoconf-$SQLITE_VERSION.tar.gz \
    && tar -xzf sqlite.tgz \
    && rm sqlite.tgz \
    && cd sqlite* \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf sqlite* \
    && ldconfig

# Install s3ql dependencies
RUN apt-get update && apt-get install -qq -y --no-install-recommends \
        pkg-config libfuse-dev attr-dev psmisc procps cron
RUN pip3 install setuptools defusedxml dugong requests pycrypto llfuse apsw

# Download and install s3ql
ENV S3QL_VERSION 2.17.1
RUN mkdir -p /data
RUN curl -ksSL -o /data/s3ql.tbz https://bitbucket.org/nikratio/s3ql/downloads/s3ql-$S3QL_VERSION.tar.bz2 \
    && tar jxf /data/s3ql.tbz -C /data \
    && mv /data/s3ql-* /data/s3ql \
    && cd /data/s3ql \
    && python3 setup.py build_ext --inplace \
    && python3 setup.py install \
    && cp contrib/expire_backups.py /usr/local/bin/ \
    && cd /data \
    && rm -rf s3ql*

# Add startup script
ADD s3ql.sh /bin/s3ql.sh

# Directory where s3ql will store write-behind cache
# This directory must be persisted between restarts,
# otherwise will auto revert to the last checkpoint.
ENV CACHE_DIR /data/cache
VOLUME $CACHE_DIR
