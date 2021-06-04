//output "docker_repository" {
//  value = aws_ecr_repository.this.repository_url
//}

locals {
  SLACK_BOT_TOKEN = jsondecode(data.aws_secretsmanager_secret_version.slackbot-secrets.secret_string)["SLACK_BOT_TOKEN"]
}

locals {
  SLACK_SIGNING_SECRET = jsondecode(data.aws_secretsmanager_secret_version.slackbot-secrets.secret_string)["SLACK_SIGNING_SECRET"]
}

locals {
  CORE_API = jsondecode(data.aws_secretsmanager_secret_version.slackbot-secrets.secret_string)["CORE_API"]
}

locals {
  MONGODB_CONNECTION_STRING = jsondecode(data.aws_secretsmanager_secret_version.core-secrets.secret_string)["MONGODB_CONNECTION_STRING"]
}

locals {
  GOOGLE_CLIENT_ID = jsondecode(data.aws_secretsmanager_secret_version.core-secrets.secret_string)["GOOGLE_CLIENT_ID"]
}