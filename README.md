# DevOp

## Build

1. Update build.conf with deployment specific configuration
2. Update module variable in build script, make sure dpedency is correct

## AWS

1. Create "_ansible" user in IAM with the following permissions:
```AmazonEC2FullAccess, AmazonS3FullAccess, AmazonRoute53FullAccess, ReadOnlyAccess```

2. Create "_registry" user in IAM with `AmazonS3FullAccess` permission.

3. Create "<prefix>-registry" bucket in S3 using `boto`, with "_registry" user account's access id and key:
```
from boto.s3.connection import S3Connection
conn = S3Connection('<aws_access_key_id>', '<aws_secret_access_key>')
from boto.s3.connection import Location
conn.create_bucket('<prefix>-registry', location=Location.USWest2)
```

## Bootstrap Docker Registry

1. Deploy the private registry service via Ansible.

2. Copy over `devop` repo and run `build -p` to build and push all images

## Bootstrap Region

1. Create new etcd discovery url and update all.yml:
```curl https://discovery.etcd.io/new?size=3```
