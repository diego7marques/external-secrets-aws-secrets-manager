## Associate the eso-role with the eks cluster with our namespace and service account
## Ref: https://github.com/external-secrets/external-secrets/issues/2951#issuecomment-1866943943
resource "aws_eks_pod_identity_association" "role_association" {
  cluster_name    = "eks-lab-cluster"
  namespace       = "external-secrets"
  service_account = "external-secrets"
  role_arn        = aws_iam_role.eso_role.arn
}