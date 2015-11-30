#!/bin/bash -xe

# move out exiting content
mkdir -p /tmp/s3ql
sudo mv $MOUNT_DIR/* /tmp/s3ql

# mount s3ql file system
sudo /bin/s3ql.sh mount \
     $MOUNT_DIR $CACHE_DIR \
     $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY \
     $FS_PATH $FS_LABEL $FS_PASSPHRASE

# copy back existing content
for dirent in /tmp/s3ql/*; do
    sudo cp -a $dirent $MOUNT_DIR
done
sudo rm -rf /tmp/s3ql

# install periodic snapshot job to minimize data loss
sudo /bin/s3ql.sh install $MOUNT_DIR $(basename $JENKINS_HOME)

/bin/tini -- /usr/local/bin/jenkins.sh
