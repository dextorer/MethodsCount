#!/bin/bash

sh 00_create_ami_factory_ec2.sh
sh 01_command_step.sh
sh 02_wait_command.sh
sh 03_tag_image.sh
sh 04_update_ebs_config.sh