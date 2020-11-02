#!/bin/bash

# Script runs as hadoop user
sudo /usr/bin/pip3 install splink
sudo /usr/bin/pip3 install graphframes
sudo /usr/bin/pip3 install pandas
sudo /usr/bin/pip3 install IPython
sudo /usr/bin/pip3 install altair
sudo /usr/bin/aws s3 cp s3://splink-emr-init-test/splink_demos.zip /tmp
/usr/bin/unzip /tmp/splink_demos.zip -d /tmp 
sudo /usr/bin/pip3 install /tmp/splink_demos
/usr/bin/aws s3 cp --recursive s3://splink-emr-init-test/jars /home/hadoop/extrajars/

