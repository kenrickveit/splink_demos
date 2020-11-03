# Private Fork to Make Splink Demos Work on AWS EMR

## Steps to run in EMR
1. Launch an EMR cluster
The example `kenrick-test-splink-4` cluster can be cloned. An example AWS CLI command to create a cluster configured for splink demos is included below. 

Important aspects of configuration:
* Use EMR 5.31.0 (or lower) to ensure Spark 2.4 or 2.3 is used. Splink is tested against these versions
* Included `splink_install.sh` as a bootstrap step, and place it on an S3 location the EMR cluster will have permissions to access
* Edit the install script if a different bucket than is referenced in the script is used to stage the splink demos and pre-req jars
* The bootstrap step will place pre-req jars at `/home/hadoop/extrajars/*` so this path must be appended to `spark.executor.extraClassPath` and `spark.driver.extraClassPath`
* The property `"spark.jars.packages":"graphframes:graphframes:0.6.0-spark2.3-s_2.11"` needs set on the cluster config to ensure graphframes is installed
* The `scala-logging-api_2.11-2.1.2.jar` and `scala-logging-slf4j_2.11-2.1.2.jar` are required for graphframes and are included in the bucket under the `jars` directory
* Ensure the cluster is configured to wait after completing any steps
* Also enable autocaling of the cluster


```
aws emr create-cluster --applications Name=Hadoop Name=Hive Name=Spark Name=Zeppelin --ec2-attributes '{"KeyName":"spark-cluster-prod","AdditionalSlaveSecurityGroups":["sg-06a3ff5a8e487ac09","sg-078d778c406da8e5b"],"InstanceProfile":"EMR_EC2_DefaultRole","ServiceAccessSecurityGroup":"sg-0cc1b871a3ae7f544","SubnetId":"subnet-33d15c1c","EmrManagedSlaveSecurityGroup":"sg-08bf1e49be8da3d2b","EmrManagedMasterSecurityGroup":"sg-0c4b4f4946acd20ce","AdditionalMasterSecurityGroups":["sg-06a3ff5a8e487ac09","sg-078d778c406da8e5b"]}' --release-label emr-5.31.0 --log-uri 's3n://aws-logs-386270690764-us-east-1/elasticmapreduce/' --instance-groups '[{"InstanceCount":1,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":2}]},"InstanceGroupType":"MASTER","InstanceType":"m5.xlarge","Name":"Master - 1"},{"InstanceCount":4,"EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"SizeInGB":32,"VolumeType":"gp2"},"VolumesPerInstance":2}]},"InstanceGroupType":"CORE","InstanceType":"m5.xlarge","Name":"Core - 2"}]' --configurations '[{"Classification":"spark-defaults","Properties":{"spark.jars.packages":"graphframes:graphframes:0.6.0-spark2.3-s_2.11","spark.executor.extraClassPath":"/usr/lib/hadoop-lzo/lib/*:/usr/lib/hadoop/hadoop-aws.jar:/usr/share/aws/aws-java-sdk/*:/usr/share/aws/emr/emrfs/conf:/usr/share/aws/emr/emrfs/lib/*:/usr/share/aws/emr/emrfs/auxlib/*:/usr/share/aws/emr/goodies/lib/emr-spark-goodies.jar:/usr/share/aws/emr/security/conf:/usr/share/aws/emr/security/lib/*:/usr/share/aws/hmclient/lib/aws-glue-datacatalog-spark-client.jar:/usr/share/java/Hive-JSON-Serde/hive-openx-serde.jar:/usr/share/aws/sagemaker-spark-sdk/lib/sagemaker-spark-sdk.jar:/usr/share/aws/emr/s3select/lib/emr-s3-select-spark-connector.jar:/home/hadoop/extrajars/*","spark.driver.extraClassPath":"/usr/lib/hadoop-lzo/lib/*:/usr/lib/hadoop/hadoop-aws.jar:/usr/share/aws/aws-java-sdk/*:/usr/share/aws/emr/emrfs/conf:/usr/share/aws/emr/emrfs/lib/*:/usr/share/aws/emr/emrfs/auxlib/*:/usr/share/aws/emr/goodies/lib/emr-spark-goodies.jar:/usr/share/aws/emr/security/conf:/usr/share/aws/emr/security/lib/*:/usr/share/aws/hmclient/lib/aws-glue-datacatalog-spark-client.jar:/usr/share/java/Hive-JSON-Serde/hive-openx-serde.jar:/usr/share/aws/sagemaker-spark-sdk/lib/sagemaker-spark-sdk.jar:/usr/share/aws/emr/s3select/lib/emr-s3-select-spark-connector.jar:/home/hadoop/extrajars/*:/home/hadoop/extrajars/*"}}]' --auto-scaling-role EMR_AutoScaling_DefaultRole --bootstrap-actions '[{"Path":"s3://splink-emr-init-test/splink_install.sh","Name":"Custom action"}]' --ebs-root-volume-size 50 --service-role EMR_DefaultRole --enable-debugging --name 'kenrick-test-splink-4' --scale-down-behavior TERMINATE_AT_TASK_COMPLETION --region us-east-1
```

2. Launch an EMR Notebook that is pointed to this new EMR cluster
3. Open the deduplication iPython notebook `quickstart_demo_deduplication.ipynb` in either `Jupyter` or `JupyterLab`. 
4. Ensure the kernel selected for the notebook is PySpark and not the default of Python

# Other Important Changes and Notes
* The notebook was changed in this repo to point to same data in S3 instead of a local filesystem so it will work in an EMR Notebook
* The charts in the demo package aren't really compatible with AWS's Jupyter/JupyterLab with Spark. I'm not yet sure of the exact reason.  However the dataframes can easily be used common and standard Python graph packages instead of these custom graph functions
* This limitation also applies to the section of the notebook where it saves the graph to HTML- it wasn't really written to work with a shared filesysem like HDFS or S3
* The `setup.py` file didn't exist in the original splink_demos repo.  This was needed to make splink_demos an installable Python package
* There is a lot of setting of Spark context settings in `utility_functions.demo_utils.get_spark`.  This doesn't really work in the EMR notebooks since the context already exists, and only some SQL values are able to be changed once the Spark context already exists.  This is why we specify the extra jar paths, the graph frames package, etc at cluster creation time.  

# splink_demos

This repo contains interactive notebooks containing demonstration and tutorial for the [splink](https://github.com/moj-analytical-services/splink) record linking library

## Running these notebooks interactively

You can run these notebooks in an interactive Jupyter notebook by clicking the button below:

[![Binder](https://mybinder.org/badge.svg)](https://mybinder.org/v2/gh/moj-analytical-services/splink_demos/master?urlpath=lab/tree/index.ipynb)
