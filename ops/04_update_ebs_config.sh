#!/bin/bash
TMP_DIR=tmp
RESPONSE=$(cat $TMP_DIR/create_image.response)
AMI_ID=$(echo $RESPONSE | sed -e 's/.*Id": "\(.*\)".*/\1/g')

function update_config {
    if [ ! -f $TMP_DIR/create_config.$1.checkpoint ]; then
        echo "Creating new configuration for ${1} with new ami-id ${2}"
		RESPONSE=$(eb config save $1 --cfg $1-$(date +%s))
		echo $RESPONSE
		CONFIG_PATH=$(echo $RESPONSE | sed -e '/^\s*$/d' -e 's/.*: \(.*\)/\1/g')
		sleep 1
		NEW_CONFIG_NAME=$1-$(date +%s)
		cat $CONFIG_PATH | sed -e "s/ImageId: .*/ImageId: ${2}/g" > $NEW_CONFIG_NAME
		eb config put $NEW_CONFIG_NAME
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
# rm -rf $TMP_DIR
# not needed for now
#update_config 'lmc-production' $AMI_ID
