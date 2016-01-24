#!/bin/sh

TMP_DIR=tmp

mkdir -p $TMP_DIR

echo "Fetching image id..."
AMI=$(aws ec2 describe-images --filters Name=name,Values=ami-factory | grep ImageId | sed -e 's/.*: "\(.*\)".*/\1/g')
echo "Launching "$AMI

BLOCK_DEVICE_MAPPING='{"VirtualName":"Root","DeviceName":"/dev/xvda","Ebs":{"SnapshotId":"snap-1cd7a135","VolumeSize":30,"DeleteOnTermination":true,"VolumeType":"gp2"}}'
IAM_INSTANCE_PROFILE='{"Name":"ec2-ssm-managed"}'

if [ ! -f $TMP_DIR/image_launch.checkpoint ]; then
	RESPONSE=$(aws ec2 run-instances --image-id $AMI --instance-type t2.micro --key-name share.nicolaseba --security-group-ids sg-2bba7f4f --iam-instance-profile $IAM_INSTANCE_PROFILE --associate-public-ip-address --block-device-mappings $BLOCK_DEVICE_MAPPING) 	
	echo $RESPONSE > $TMP_DIR/image_launch.response
	touch $TMP_DIR/image_launch.checkpoint
fi

if [ ! -f $TMP_DIR/command.checkpoint ]; then
	RESPONSE=$(cat image_launch.response)
	INSTANCE_ID=$(echo $RESPONSE | sed -e 's/.*InstanceId": "\(.*\)", "ImageId.*/\1/g')
	echo $INSTANCE_ID > $TMP_DIR/instance_id
	echo "Waiting for instance ${INSTANCE_ID} to be available..."
	until RUNNING=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID | grep running)
	do
		sleep 1
	done
	echo "Instance is running"
	echo "Updating sdk"
	RESPONSE=$(aws ssm send-command --document-name AWS-RunShellScript --parameters '{"commands":["echo y | android-sdk-linux/tools/android update sdk --no-ui"],"workingDirectory":["/var/android"],"executionTimeout":["3600"]}' --instance-ids $INSTANCE_ID --output-s3-bucket-name ami-provisioning-log)
	echo $RESPONSE > $TMP_DIR/command_response.json
	touch $TMP_DIR/command.checkpoint
fi

RESPONSE=$(cat $TMP_DIR/command_response.json)
COMMAND_ID=$(echo $RESPONSE | sed -e 's/.*CommandId": "\(.*\)", "Requ.*/\1/g')
echo "Waiting for update command id ${COMMAND_ID} to finish ."
until DONE=$(aws s3 ls s3://ami-provisioning-log/$COMMAND_ID)
do
	sleep 5
done

echo "Command executed"

if [ ! -f $TMP_DIR/create_image.checkpoint ]; then
	echo "Creating image..."
	DATE=`date +%Y-%m-%d`
	RESPONSE=$(aws ec2 create-image --instance-id $INSTANCE_ID --name ami-factory-$DATE)
	echo $RESPONSE > $TMP_DIR/create_image.response
	touch $TMP_DIR/create_image.checkpoint
fi

RESPONSE=$(cat $TMP_DIR/create_image.response)
AMI_ID=$(echo $RESPONSE | sed -e 's/.*Id": "\(.*\)".*/\1/g')
echo "Waiting for ami id ${AMI_ID} to be created..."
until AVAILABLE=$(aws ec2 describe-images --image-ids $AMI_ID | grep State | sed -e 's/.*: "\(.*\)".*/\1/g' | grep available)
do
	sleep 5
done

echo "Image created"

if [ ! -f $TMP_DIR/instance_terminated.checkpoint ]; then
	INSTANCE_ID=$(cat $TMP_DIR/instance_id)
	aws ec2 terminate-instances --instance-ids $INSTANCE_ID
	touch $TMP_DIR/instance_terminated.checkpoint
fi

function update_config {
        if [ ! -f $TMP_DIR/create_config.$1.checkpoint ]; then
        	echo "Creating new configuration for ${1} with new ami-id ${2}"
		RESPONSE=$(eb config save $1 --cfg $TMP_DIR/$1-$(date +%s))
		CONFIG_PATH=$(echo $RESPONSE | sed -e '/^\s*$/d' -e 's/.*: \(.*\)/\1/g')
		NEW_CONFIG_NAME=$1-$(date +%s)
		cat $CONFIG_PATH | sed -e "s/ImageId: .*/ImageId: ${2}/g" > $TMP_DIR/$NEW_CONFIG_NAME
		eb config put $TMP_DIR/$NEW_CONFIG_NAME
		echo $NEW_CONFIG_NAME > $TMP_DIR/config_name.$1
		touch $TMP_DIR/create_config.$1.checkpoint
	fi
	if [ ! -f $TMP_DIR/update_environment.$1.checkpoint ]; then
		NEW_CONFIG_NAME=$(cat $TMP_DIR/config_name.$1)
		echo "Starting environment ${1} update. New ami id: ${2}"
		aws elasticbeanstalk update-environment --application-name lmc --environment-name $1 --template-name $NEW_CONFIG_NAME
        	until READY=$(eb status $1 | grep Ready)
		do
			sleep 5
		done
		aws elasticbeanstalk restart-app-server --environment-name $1	
		touch $TMP_DIR/update_environment.$1.checkpoint
	fi	
}

update_config 'lmc-workers-production' $AMI_ID
rm -rf $TMP_DIR
# not needed for now
#update_config 'lmc-production' $AMI_ID

echo "Success"

