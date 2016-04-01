# AWS Notes for filling in values

 1. Download and install AWS CLI bits http://docs.aws.amazon.com/cli/latest/userguide/installing.html
 1. Configure the CLI bits http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
 1. Go to the AWS Console web page and setup an "Access Key" and an "SSH Public Key" https://console.aws.amazon.com/iam/home?region=us-west-2#users/davidbrown
 1. Setup a session to start the cluster (the session token, key id and access key goes into the Vagrantfile)
```
aws sts --profile davidbrown@salishsea get-session-token --duration-seconds 3600
```
 1. Find the AMI for the basic CentOS image (magic product code came from wiki.centos.org)
```
aws --profile davidbrown@salishsea --region us-west-2 ec2 describe-images --owners aws-marketplace --filters Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce
```
 1. Change the path to the private key in the vagrant file
 1. Accept the license for the official CentOS image.
