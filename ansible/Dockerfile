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

ENV ANSIBLE_URL=https://github.com/ansible/ansible.git
ENV ANSIBLE_BRANCH=v2.0.0.1-1

COPY patch /patch
#    mkdir -p ./lib/ansible/modules/core/cloud/amazon && \
#    mv /patch/amazon/* ./lib/ansible/modules/core/cloud/amazon/ && \
#    mv /patch/os/* ./lib/ansible/modules/core/packaging/os/ && \
RUN git clone -b $ANSIBLE_BRANCH --recursive $ANSIBLE_URL /app && \
    cd /app && \
    groupadd -g 1000 ansible && \
    useradd -m ansible -u 1000 -g 1000 && \
    python setup.py install && \
    rm -rf /app
RUN pip install -r /patch/requirements.txt

COPY src /etc/ansible 
RUN chown -Rf ansible. /etc/ansible && \
    cp -v /etc/ansible/scripts/main /usr/local/sbin

USER ansible
WORKDIR /etc/ansible/plays
ENTRYPOINT [ "ansible" ] 
