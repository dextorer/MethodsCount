#!/bin/bash
TMP_DIR=tmp
RESPONSE=$(cat $TMP_DIR/create_image.response)
AMI_ID=$(echo $RESPONSE | sed -e 's/.*Id": "\(.*\)".*/\1/g')
if [ ! -f $TMP_DIR/image_created.checkpoint ]; then
	echo "Waiting for ami id ${AMI_ID} to be created..."
	until AVAILABLE=$(aws ec2 describe-images --image-ids $AMI_ID | grep State | sed -e 's/.*: "\(.*\)".*/\1/g' | grep available)
	do
		sleep 5
	done

	echo "Image created"
	OLD_AMI=$(cat $TMP_DIR/ami)
	aws ec2 delete-tags --resources $OLD_AMI --tags "Key=Version,Value=current"
	aws ec2 create-tags --resources $AMI_ID --tags "Key=Version,Value=current" "Key=App,Value=lmc"
	touch $TMP_DIR/create_image.checkpoint
fi

if [ ! -f $TMP_DIR/instance_terminated.checkpoint ]; then
	INSTANCE_ID=$(cat $TMP_DIR/instance_id)
	aws ec2 terminate-instances --instance-ids $INSTANCE_ID
	touch $TMP_DIR/instance_terminated.checkpoint
fi