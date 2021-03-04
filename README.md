# TerraformWebApp
Please use your own access and secret key
Below are the resources created:

A VPC
Two public subnets
One private subnet
An Elastic BeanStalk Application to deploy and manage application
Created a loadbalancer as well as autoscaling group

Load Balancer is in public facing subnet
Minimum capacity of auto scaling group is 1 and maximum is 2.
Kept a health check on the instance
Used Windows Server 2019 as a web server
Used t2.micre as instance as its a free tier in AWS.
Open HTTP 80 port as of now.
