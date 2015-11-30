#!/bin/bash -xe

# move out exiting content
mkdir -p /tmp/home
sudo mv $JENKINS_HOME /tmp/home
sudo mkdir -p $JENKINS_HOME

# mount s3ql file system
sudo /bin/s3ql.sh mount \
     $JENKINS_HOME $CACHE_DIR \
     $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY \
     $FS_PATH $FS_LABEL $FS_PASSPHRASE

# copy back existing content
for dirent in /tmp/home/*; do
    sudo cp -a $dirent $(dirname $JENKINS_HOME)
done
sudo rm -rf /tmp/home

/bin/tini -- /usr/local/bin/jenkins.sh
