#
# BRICKLY.IO CONFIDENTIAL
# ______________________________
#
#  [2015] - [2016] Brickly.io Incorporated
#  All Rights Reserved.
#
# NOTICE: All information contained herein is, and remains the property of Brickly.io Incorporated
# and its suppliers, if any.  The intellectual and technical concepts contained herein are
# proprietary to Brickly.io Incorporated and its suppliers and may be covered by U.S. and Foreign
# Patents, patents in process, and are protected by trade secret or copyright law. Dissemination of
# this information or reproduction of this material is strictly forbidden unless prior written
# permission is obtained from Brickly.io Incorporated.
#

FROM debian:jessie

# enable non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm

# disable apt-get cache
RUN echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache

# install base packages
RUN apt-get update -yqq && \
    apt-get -yqq dist-upgrade && \
    apt-get -yqq --force-yes install \
      curl wget git-core vim locales apt-transport-https

# add self-signed certificate
# openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout private.key -out private.crt
# todo: is this still needed?
COPY internal.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates
