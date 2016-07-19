#!/bin/bash
TMP_DIR=tmp

if [ ! -f $TMP_DIR/command.checkpoint ]; then
	RESPONSE=$(cat $TMP_DIR/image_launch.response)
	INSTANCE_ID=$(echo $RESPONSE | sed -e 's/.*InstanceId": "\(.*\)", "ImageId.*/\1/g')
	echo $INSTANCE_ID > $TMP_DIR/instance_id
	echo "Waiting for instance ${INSTANCE_ID} to be available..."
	sleep 10
	until RUNNING=$(aws ec2 describe-instance-status --instance-ids $INSTANCE_ID | grep passed)
	do
		sleep 1
	done
	sleep 10
	echo "Instance is running"
	echo "Updating sdk on instance id "$INSTANCE_ID
	COMMAND="aws ssm send-command --document-name AWS-RunShellScript --parameters '{\"commands\":[\"echo y | android-sdk-linux/tools/android update sdk --no-ui\"],\"workingDirectory\":[\"/var/android\"],\"executionTimeout\":[\"3600\"]}' --instance-ids $INSTANCE_ID --output-s3-bucket-name ami-provisioning-log"
	echo $COMMAND
	RESPONSE=$(eval $COMMAND)
	echo $RESPONSE > $TMP_DIR/command_response.json
	touch $TMP_DIR/command.checkpoint
fi