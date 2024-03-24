## Create the base eso-role for the operator service account
resource "aws_iam_role" "eso_role" {
  name = "eso-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
      Effect = "Allow"
      Principal = {
        Service = [
					"pods.eks.amazonaws.com"
				]
      }
    }]
  })
}

## Create the eso-role for the operator
resource "aws_iam_role" "workload01_eso_role" {
  name = "workload01-eso-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
      Effect = "Allow"
      Principal = {
        AWS = aws_iam_role.eso_role.arn
      }
    }]
  })
}

## Create the policy document with the required actions over the secret created in the last step
## Ref: https://external-secrets.io/v0.9.13/provider/aws-secrets-manager/
data "aws_iam_policy_document" "eso_policy" {
    statement {
      sid = "eso"
      effect = "Allow"
      actions = [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ]
      resources = [
        aws_secretsmanager_secret.secret.arn
      ]
    }

    statement {
      sid = "allowListSecrets"
      effect = "Allow"
      actions = [ 
        "secretsmanager:ListSecrets"
      ]
      resources = [
        "*"
      ]
    }
}

## Create the IAM policy with the document created above
resource "aws_iam_policy" "eso_policy" {
  name        = "eso-policy"
  description = "Policy for ExternalSecretsOperator read content from SecretsManager of workload01"
  policy      = data.aws_iam_policy_document.eso_policy.json
}

## Associate the policy with the workload-eso-role
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.workload01_eso_role.name
  policy_arn = aws_iam_policy.eso_policy.arn
}