#!/bin/bash

set -e

AWS_ACCOUNT_ID=''
AWS_ACCESS_KEY_ID=''
AWS_SECRET_ACCESS_KEY=''
AWS_DEFAULT_REGION=''

EC2_CERT='certificates/cert.pem'
EC2_PRIVATE_KEY='certificates/pk.pem'

EC2_SOURCE_AMI=''
EC2_VPC_ID=''
EC2_SUBNET_ID=''

S3_BUCKET='packer-image-builder'

export AWS_ACCOUNT_ID AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION
export EC2_CERT EC2_PRIVATE_KEY
export EC2_SOURCE_AMI EC2_VPC_ID EC2_SUBNET_ID
export S3_BUCKET

for job in 'validate' 'build --color=false'; do
    packer $job -only=amazon-ebs "$@"
done

exit $?
