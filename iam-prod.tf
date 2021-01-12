###
# prod-deploy
# The role used by the "tools" account to deploy resources in the
# "prod" account.
resource aws_iam_role prod_deploy {
  provider           = aws.prod
  name               = "prod-deploy"
  assume_role_policy = data.aws_iam_policy_document.assume_deploy.json
}
data aws_iam_policy_document assume_deploy {
  statement {
    actions = [
      "sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [
        aws_iam_role.tools_codepipeline.arn]
    }
  }
}

###
# tools-kms Policy
# Provide access to the "tools" KMS key for decrypting codepipeline
# artifacts stored in S3.
data aws_iam_policy_document tools_kms {
  statement {
    actions   = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt"
    ]
    resources = [
      aws_kms_key.tools_s3.arn
    ]
  }
}
resource aws_iam_policy tools_kms {
  provider = aws.prod
  name     = "tools-kms"
  policy   = data.aws_iam_policy_document.tools_kms.json
}
resource aws_iam_role_policy_attachment tools_kms {
  provider   = aws.prod
  role       = aws_iam_role.prod_deploy.name
  policy_arn = aws_iam_policy.tools_kms.arn
}

###
# tools-artifacts
# Provide access to the codepipeline artifacts stored in the "tools"
# account S3 bucket.
data aws_iam_policy_document tools_artifacts {
  statement {
    actions   = [
      "s3:Get*"]
    resources = [
      "${aws_s3_bucket.pipeline_artifacts.arn}/*"]
  }
  statement {
    actions   = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.pipeline_artifacts.arn]
  }
}
resource aws_iam_policy tools_artifacts {
  provider = aws.prod
  name     = "tools-artifacts"
  policy   = data.aws_iam_policy_document.tools_artifacts.json
}
resource aws_iam_role_policy_attachment tools_artifacts {
  provider   = aws.prod
  role       = aws_iam_role.prod_deploy.name
  policy_arn = aws_iam_policy.tools_artifacts.arn
}

###
# prod-web
# Provide access to the target S3 deployment bucket.
data aws_iam_policy_document prod_web {
  statement {
    actions   = [
      "s3:Get*",
      "s3:Put*"]
    resources = [
      "${aws_s3_bucket.prod.arn}/*"]
  }
  statement {
    actions   = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.prod.arn]
  }
}
resource aws_iam_policy prod_web {
  provider = aws.prod
  name     = "prod-web"
  policy   = data.aws_iam_policy_document.prod_web.json
}
resource aws_iam_role_policy_attachment prod_web {
  provider   = aws.prod
  role       = aws_iam_role.prod_deploy.name
  policy_arn = aws_iam_policy.prod_web.arn
}

