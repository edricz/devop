#!/bin/bash -xe
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

do_install() {
    # install pre-reqs
    apt-get install -y \
            build-essential libfuse-dev libcurl4-openssl-dev libxml2-dev \
            mime-support automake libtool pkg-config libssl-dev

    # download and build from source
    wget https://github.com/s3fs-fuse/s3fs-fuse/archive/v$S3FS_VERSION.tar.gz \
         -O /usr/src/v$S3FS_VERSION.tar.gz
    tar xvz -C /usr/src -f /usr/src/v$S3FS_VERSION.tar.gz
    cd /usr/src/s3fs-fuse-$S3FS_VERSION
    ./autogen.sh
    ./configure --prefix=/usr
    make
    make install

    # cleanup
    rm -rf /usr/src/v$S3FS_VERSION.tar.gz
    rm -rf /usr/src/s3fs-*
    apt-get purge -y build-essential pkg-config automake mime-support
    apt-get autoremove -y
}

do_mount() {
    # create credential file
    echo "${AWS_ACCESS_KEY_ID}:${AWS_SECRET_ACCESS_KEY}" > /tmp/.s3fs
    sudo mv /tmp/.s3fs /root/.s3fs
    sudo chmod 400 /root/.s3fs

    # move out exiting content
    mkdir /tmp/s3fs
    sudo mv $S3FS_MOUNT/* /tmp/s3fs

    # mount s3 file system
    sudo /usr/bin/s3fs -o passwd_file=/root/.s3fs -o allow_other -o use_cache=/tmp $S3FS_BUCKET $S3FS_MOUNT

    # copy back existing content
    for dirent in /tmp/s3fs/*; do
        sudo cp -a $dirent $S3FS_MOUNT
    done
    sudo rm -rf /tmp/s3fs
}

if [ _$1 == "_install" ]; then
    do_install
elif [ _$1 == "_mount" ]; then
    do_mount
else
    echo "Usage: $0 <install|mount>"
    exit 1
fi
