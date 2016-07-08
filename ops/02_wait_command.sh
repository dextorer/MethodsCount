#!/bin/bash
TMP_DIR=tmp

RESPONSE=$(cat $TMP_DIR/command_response.json)
COMMAND_ID=$(echo $RESPONSE | sed -e 's/.*CommandId": "\(.*\)", "Requ.*/\1/g')
echo "Waiting for update command id ${COMMAND_ID} to finish ."
until DONE=$(aws s3 ls s3://ami-provisioning-log/$COMMAND_ID)
do
	sleep 5
done

echo "Command executed"

if [ ! -f $TMP_DIR/create_image.checkpoint ]; then
	INSTANCE_ID=$(cat $TMP_DIR/instance_id)
	echo "Creating image..."
	DATE=`date +%Y-%m-%d`
	RESPONSE=$(aws ec2 create-image --instance-id $INSTANCE_ID --name ami-factory-$DATE)
	echo $RESPONSE > $TMP_DIR/create_image.response
	touch $TMP_DIR/create_image.checkpoint
fi