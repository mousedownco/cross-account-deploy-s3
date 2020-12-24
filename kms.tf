data aws_iam_role tools_role {
  provider = aws.tools
  name     = var.tools_account_role
}

resource aws_kms_key tools_s3 {
  provider    = aws.tools
  description = "TOOLS encryption key"
}

resource aws_kms_alias tools_s3 {
  provider      = aws.tools
  target_key_id = aws_kms_key.tools_s3.id
  name          = "alias/tools/s3"
}

resource aws_kms_grant codepipeline {
  provider          = aws.tools
  name              = "codepipeline"
  key_id            = aws_kms_key.tools_s3.id
  grantee_principal = aws_iam_role.tools_codepipeline.arn
  operations        = [
    "Encrypt",
    "Decrypt",
    "GenerateDataKey"]
}

resource aws_kms_grant prod {
  provider          = aws.tools
  name              = "prod"
  key_id            = aws_kms_key.tools_s3.id
  grantee_principal = "arn:aws:iam::${var.prod_account_number}:root"
  operations        = [
    "Encrypt",
    "Decrypt",
    "GenerateDataKey"]
}
