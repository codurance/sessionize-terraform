terraform {
  backend "s3" {
    bucket = "sessionize-test-bucket"
    key = "./state.tfstate"
    region = "eu-west-2"
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">=0.14.9"
}

provider "aws" {
  region = "eu-north-1"
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "3.0.0"
  name               = "sessionize-dev"
  cidr               = "10.0.0.0/16"
  azs                = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway = true
}

module "ecs" {
  source = "./modules/ecs"
  env = "dev"
  app_list = ["slackbot", "core"]
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets
  slackbot_env_arn = "arn:aws:secretsmanager:eu-north-1:300563897675:secret:slackbot-env-dev-BZqZul"
  core_env_arn = "arn:aws:secretsmanager:eu-north-1:300563897675:secret:core-env-dev-W2j546"
}