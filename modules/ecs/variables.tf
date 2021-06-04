variable "env" {
  type        = string
  description = "The name of the environment"
}

variable "slackbot-ecr" {
  type        = string
  description = "The name of the ECR repository for the Sessionize Slackbot"
}

variable "core-ecr" {
  type        = string
  description = "The name of the ECR repository for the Sessionize Core API"
}

variable "vpc_id" {
  type        = string
  description = "The resource ID of the project's VPC"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "A list of public subnet IDs"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "A list of private subnet IDs"
}

variable "slackbot_env_arn" {
  type        = string
  description = "Slackbot environment variables ARN in Secrets Manager"
}

variable "core_env_arn" {
  type        = string
  description = "Core API environment variables ARN in Secrets Manager"
}
