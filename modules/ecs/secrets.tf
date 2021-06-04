data "aws_secretsmanager_secret" "slackbot-env" {
  arn = var.slackbot_env_arn
}

data "aws_secretsmanager_secret_version" "slackbot-secrets" {
  secret_id = data.aws_secretsmanager_secret.slackbot-env.id
}

data "aws_secretsmanager_secret" "core-env" {
  arn = var.core_env_arn
}

data "aws_secretsmanager_secret_version" "core-secrets" {
  secret_id = data.aws_secretsmanager_secret.core-env.id
}