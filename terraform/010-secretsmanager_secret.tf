resource "aws_secretsmanager_secret" "secret" {
  name = "containscloud-lab-secret"
}

resource "aws_secretsmanager_secret_version" "secret_verison" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode({
    sqldb_host = "db01.database.com"
    sqldb_user = "app01_operator"
    sqldb_password = "@helloworld"
    oracledb_host = "db01.oracle.com"
  })
}