#!/bin/bash

sudo sed -i.orig -r 's/^[[:space:]]*hostname=.*/hostname='$1'/' /etc/ambari-agent/conf/ambari-agent.ini
