provider "aws" {
 access_key = ""
 secret_key = ""
 region     =   "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16" 
  tags = {
    Name = "test-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "private"
  }
}

resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "public"
  }
}

resource "aws_elastic_beanstalk_application" "ebs_app" {
  name        = "elastic_beanstalk_application"
  description = "Ebs App"
}

resource "aws_elastic_beanstalk_environment" "ebs_environment" {
  name                               = "ebs environment"
  description                        = "Test elastic_beanstalk_environment"
  application                        = aws_elastic_beanstalk_application.ebs_app.name
  solution_stack_name                = "64bit Windows Server 2019 v2.6.3 running IIS 10.0"
  tier                               = "WebServer"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.vpc.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = aws_subnet.private.id
  }

   setting {
    name = "MinSize"
    resource = "AWSEBAutoScalingGroup"
    namespace = "aws:autoscaling:asg"
    value = aws_autoscaling_group.asg_group.min_size
  } 

  setting {
    name = "MaxSize"
    resource = "AWSEBAutoScalingGroup"
    namespace = "aws:autoscaling:asg"
    value = aws_autoscaling_group.asg_group.max_size
    }  

   setting {
    name = "LoadBalencers"
    resource = "AWSEBLoadBalencers"
    namespace = "aws:elb:loadbalancer"
    value = aws_lb.test.name
    }
}

resource "aws_launch_template" "launchtemplate" {
  name_prefix   = "LatestWindowstemplate"
  image_id      = "ami-02642c139a9dfb378"
  instance_type = "t2.micro"
} 

resource "aws_autoscaling_group" "asg_group" {
  availability_zones = ["us-east-1a", "us-east-1b"]
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1

   launch_template {
    id      = aws_launch_template.launchtemplate.id
    version = "$Latest"
  } 
  
}

resource "aws_lb" "test" {
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http_ssh.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public1.id ]
 
  enable_deletion_protection = true

  tags = {
    Environment = "test"
  }
}

resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.vpc.id
  
ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

tags = {
    Name = "allow_http_ssh"
  }

}
