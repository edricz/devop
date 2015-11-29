#!/bin/bash -xe

/bin/s3fs.sh mount
/bin/tini -- /usr/local/bin/jenkins.sh
