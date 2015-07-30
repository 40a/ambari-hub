#!/bin/bash

echo 'preserve_hostname: true' | sudo tee --append /etc/cloud/cloud.cfg
sudo hostnamectl --static set-hostname $1
sudo hostname $1
sudo sed -i.orig -r 's/^[[:space:]]*hostname=.*/hostname='$2'/' /etc/ambari-agent/conf/ambari-agent.ini
