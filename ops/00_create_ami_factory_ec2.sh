#!/bin/sh

TMP_DIR=tmp

mkdir -p $TMP_DIR

echo "Fetching image id..."
AMI=$(aws ec2 describe-images --filters "Name=tag:Version,Values=current" "Name=tag:App,Values=lmc" | grep ImageId | sed -e 's/.*: "\(.*\)".*/\1/g')

if [ -z "$AMI" ]; then
	echo "Valid ami doesn't exist"
	exit 1
fi

echo "Launching "$AMI
echo $AMI > $TMP_DIR/ami

BLOCK_DEVICE_MAPPING='{"VirtualName":"Root","DeviceName":"/dev/xvda","Ebs":{"VolumeSize":30,"DeleteOnTermination":true,"VolumeType":"gp2"}}'
IAM_INSTANCE_PROFILE='{"Name":"ec2-ssm-managed"}'

if [ ! -f $TMP_DIR/image_launch.checkpoint ]; then
	RESPONSE=$(aws ec2 run-instances --image-id $AMI --instance-type t2.micro --key-name share.nicolaseba --security-group-ids sg-2bba7f4f --iam-instance-profile $IAM_INSTANCE_PROFILE --associate-public-ip-address --block-device-mappings $BLOCK_DEVICE_MAPPING) 	
	echo $RESPONSE > $TMP_DIR/image_launch.response
	touch $TMP_DIR/image_launch.checkpoint
fi
