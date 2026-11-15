terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 6.56.0"
        }
    }
}

data "aws_ami" "learning_app_ami" {
    most_recent = true

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type" # hardware virtial machine
        values = ["hvm"]
    }

    owners = ["099720109477"] # ubuntu
}

module "learning_app_vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "~> 5.0"

    name = "dev"
    cidr = "10.0.0.0/16"

    azs = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
    public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

    tags = {
        Terraform = "true"
        Environment = "dev"
    }
}


module "learning_app_autoscaling" {
    source  = "terraform-aws-modules/autoscaling/aws"
    version  = "~> 9.0"

    name = "learning-app-asg"

    min_size = 1
    max_size = 3
    vpc_zone_identifier = module.learning_app_vpc.public_subnets
    traffic_source_attachments = {
    alb = {
      traffic_source_identifier = module.learning_app_alb.target_group_arns[0]
      traffic_source_type       = "elbv2"
    }
  }
    security_groups = [module.learning_app_sg.security_group_id]
    instance_type = var.instance_type
    image_id = data.aws_ami.learning_app_ami.id
}

module "learning_app_alb" {
    source  = "terraform-aws-modules/alb/aws"
    version = "~> 8.0"

    name = "learning-app-alb"

    load_balancer_type = "application"

    vpc_id = module.learning_app_vpc.vpc_id
    subnets = module.learning_app_vpc.public_subnets
    security_groups = [module.learning_app_vpc.default_security_group_id]

    target_groups = [
        {
            name_prefix      = "app-"
            backend_protocol = "HTTP"
            backend_port     = 80
            target_type      = "instance"
        }
    ]

    http_tcp_listeners = [
        {
            port               = 80
            protocol           = "HTTP"
            target_group_index = 0
        }
    ]

    tags = {
        Environment = "dev"
    }
}

module "learning_app_sg" {
    source = "terraform-aws-modules/security-group/aws"
    version = "~> 4.0"

    vpc_id = module.learning_app_vpc.vpc_id
    name = "learning-app-sg"
    ingress_rules = ["https-443-tcp", "http-80-tcp"]
    ingress_cidr_blocks = ["0.0.0.0/0"]
    egress_rules = ["all-all"]
    egress_cidr_blocks = ["0.0.0.0/0"]

}