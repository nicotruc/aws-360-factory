#!/usr/bin/env bash

set -e

######################################################################
# Variable definition
######################################################################

export AWS_DEFAULT_OUTPUT=text

######################################################################
# Get the AMI_ID
######################################################################

echo "Getting AMI Id..."
EC2_AMI_NAME="ubuntu/images/hvm-ssd/ubuntu-xenial-*"
EC2_AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=${EC2_AMI_NAME}" --query 'reverse(sort_by(Images, &CreationDate)) | [0].ImageId')
echo "Got AMI Id: ${EC2_AMI_ID}"

######################################################################
# Get the VPC Id
######################################################################

echo "Getting VPC Id..."

EC2_VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[?IsDefault] | [0].VpcId')

echo "Got VPC Id: ${EC2_VPC_ID}"

######################################################################
# Get the Subnet Id within the VPC
######################################################################

echo "Getting Subnet Id..."

EC2_SUBNET_ID=$(aws ec2 describe-subnets --query "Subnets[?VpcId == '${EC2_VPC_ID}' && AvailabilityZone == 'us-east-1b'] | [0].SubnetId")

echo "Got Subnet Id: ${EC2_SUBNET_ID}"

######################################################################
# Get the Security groups Id
######################################################################

echo "Getting Security Group Id..."

EC2_SG_ID=$(aws ec2 describe-security-groups --query "SecurityGroups[?VpcId == '${EC2_VPC_ID}' && GroupName == 'default'] | [0].GroupId")

echo "Got Security Group Id: ${EC2_SG_ID}"

######################################################################
### Provision EC2 Server
######################################################################

echo "Provisioning EC2 instance..."

EC2_PROVISION=$(aws ec2 run-instances --image-id "${EC2_AMI_ID}" --count=1 --instance-type "t2.micro" --key-name "ESIEE" --security-group-ids "${EC2_SG_ID}" --subnet-id "${EC2_SUBNET_ID}")

echo "Ec2 Instance ready, here are the details:"
echo ${EC2_PROVISION}
