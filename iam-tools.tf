###
# tools-codepipeline
# The role used by codepipeline to deploy resources to in the "prod"
# account
resource aws_iam_role tools_codepipeline {
  provider           = aws.tools
  name               = "tools-codepipeline"
  assume_role_policy = data.aws_iam_policy_document.assume_tools_codepipeline.json
}
data aws_iam_policy_document assume_tools_codepipeline {
  statement {
    actions = [
      "sts:AssumeRole"]
    principals {
      identifiers = [
        "codepipeline.amazonaws.com"]
      type        = "Service"
    }
  }
}

###
# tools-codepipeline
# Provide access to resources needed by codepipeline to build projects.
resource aws_iam_policy tools_codepipeline {
  provider = aws.tools
  name     = "tools-codepipeline"
  policy   = data.aws_iam_policy_document.tools_codepipeline.json
}
data aws_iam_policy_document tools_codepipeline {
  statement {
    actions   = [
      "codestar-connections:UseConnection"
    ]
    resources = [
      "*"]
  }
  statement {
    actions   = [
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "sqs:*"
    ]
    resources = [
      "*"]
  }
  statement {
    actions   = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch"
    ]
    resources = [
      "*"]
  }
}
resource aws_iam_role_policy_attachment tools_codepipeline {
  provider   = aws.tools
  role       = aws_iam_role.tools_codepipeline.name
  policy_arn = aws_iam_policy.tools_codepipeline.arn
}


###
# assume-prod-deploy
# Permit the "tools-codepipeline" role to assume the "prod-deploy" role
# in the "prod" account.
data aws_iam_policy_document assume_prod_deploy {
  statement {
    actions   = [
      "sts:AssumeRole"]
    resources = [
      aws_iam_role.prod_deploy.arn]
  }
}
resource aws_iam_policy assume_prod_deploy {
  provider           = aws.tools
  name = "assume-prod-deploy"
  policy = data.aws_iam_policy_document.assume_prod_deploy.json
}
resource aws_iam_role_policy_attachment assume_prod_deploy {
  provider           = aws.tools
  role = aws_iam_role.tools_codepipeline.name
  policy_arn = aws_iam_policy.assume_prod_deploy.arn
}
