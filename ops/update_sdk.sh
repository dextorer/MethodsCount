#!/bin/sh

echo "Fetching image id..."
AMI=$(aws ec2 describe-images --filters Name=name,Values=ami-factory | grep ImageId | sed -e 's/.*: "\(.*\)".*/\1/g')
echo "Launching "$AMI

BLOCK_DEVICE_MAPPING='{"VirtualName":"Root","DeviceName":"/dev/xvda","Ebs":{"SnapshotId":"snap-1cd7a135","VolumeSize":30,"DeleteOnTermination":true,"VolumeType":"gp2"}}'
IAM_INSTANCE_PROFILE='{"Name":"ec2-ssm-managed"}'

RESPONSE=$(aws ec2 run-instances --image-id $AMI --instance-type t2.micro --key-name share.nicolaseba --security-group-ids sg-2bba7f4f --iam-instance-profile $IAM_INSTANCE_PROFILE --associate-public-ip-address --block-device-mappings $BLOCK_DEVICE_MAPPING) 
INSTANCE_ID=$(echo $RESPONSE | sed -e 's/.*InstanceId": "\(.*\)", "ImageId.*/\1/g')
echo "Waiting for instance ${INSTANCE_ID} to be available..."

until RUNNING=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID | grep running)
do
	sleep 1
done

echo "Instance is running"
echo "Updating sdk"
RESPONSE=aws ssm send-command --document-name AWS-RunShellScript --parameters '{"commands":["echo y | android-sdk-linux/tools/android update sdk --no-ui"],"workingDirectory":["/var/android"]}' --instance-ids $INSTANCE_ID --output-s3-bucket-name ami-provisioning-log
COMMAND_ID=$(echo $RESPONSE | sed -e 's/.*CommandId": "\(.*\)", "Requ.*/\1/g')
until SUCCESS=$(aws ssm list-command-invocations | sed -e 's/.*CommandId": "\(.*\)", "Requ.*/\1/g'

