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

FROM i-docker.brickly.io/python2:latest
ENV version=1

ENV DOCKER_GEN_VERSION=0.7.0
ENV DOCKER_GEN_URL https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz

ENV DOCKER_HOST unix:///var/run/docker.sock

RUN apt-get install -yqq --no-install-recommends libffi-dev libssl-dev \
    && cd /tmp && wget $DOCKER_GEN_URL \
    && tar xvzf docker-gen-linux-amd64*.tar.gz -C /usr/local/bin \ 
    && rm -vf /tmp/docker-gen-linux*

ADD requirements.pip /
RUN pip install -r requirements.pip

ADD . /app
WORKDIR /app

CMD docker-gen -interval 5 -watch -notify "python /tmp/register.py" etcd.tmpl /tmp/register.py
