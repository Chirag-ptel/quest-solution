data "aws_secretsmanager_secret" "quest_secret" {
  name = "quest-secret"
}

data "aws_secretsmanager_secret_version" "quest_secret_version" {
  secret_id     = data.aws_secretsmanager_secret.quest_secret.id
}