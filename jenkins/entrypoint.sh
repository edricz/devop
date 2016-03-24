#!/bin/bash -xe

# mount s3ql file system
sudo /bin/s3ql.sh mount \
     $MOUNT_DIR $CACHE_DIR \
     $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY \
     $FS_PATH $FS_LABEL $FS_PASSPHRASE

# install periodic snapshot job to minimize data loss
sudo mkdir -p $JENKINS_HOME
sudo chown jenkins:jenkins $JENKINS_HOME
sudo /bin/s3ql.sh install $MOUNT_DIR $(basename $JENKINS_HOME)

/bin/tini -- /usr/local/bin/jenkins.sh
