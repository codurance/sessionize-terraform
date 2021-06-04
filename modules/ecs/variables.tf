variable "env" {
  type        = string
  description = "The name of the environment"
}

variable "app_list" {
  type = list(string)
  description = "A list of all the ECR repos to create"
}

variable "vpc_id" {
  type = string
  description = "The resource ID of the project's VPC"
}

variable "public_subnet_ids" {
  type = list(string)
  description = "A list of public subnet IDs"
}

variable "private_subnet_ids" {
  type = list(string)
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
