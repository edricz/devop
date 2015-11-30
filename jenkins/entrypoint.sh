#!/bin/bash -xe

# move out exiting content
mkdir -p /tmp/home
sudo mv $JENKINS_HOME/* /tmp/home
export MOUNT_DIR=$JENKINS_HOME

# mount s3ql file system
/bin/s3ql.sh mount

# copy back existing content
for dirent in /tmp/home/*; do
    sudo cp -a $dirent $JENKINS_HOME
done
sudo rm -rf /tmp/home

/bin/tini -- /usr/local/bin/jenkins.sh
