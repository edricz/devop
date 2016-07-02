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

RUN apt-get install -yqq --force-yes --no-install-recommends \
      build-essential python python-dev python-virtualenv
RUN wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py \
    && python /tmp/get-pip.py
