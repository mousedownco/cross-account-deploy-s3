resource aws_codepipeline prod_deploy {
  provider = aws.tools
  name     = "prod-deploy"
  role_arn = aws_iam_role.tools_codepipeline.arn
  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.pipeline_artifacts.bucket

    encryption_key {
      id   = aws_kms_alias.tools_s3.arn
      type = "KMS"
    }
  }
  stage {
    name = "Source"
    action {
      category         = "Source"
      name             = "s3-source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      region           = var.tools_region
      configuration    = {
        PollForSourceChanges = false
        S3Bucket             = aws_s3_bucket.source.bucket
        S3ObjectKey          = aws_s3_bucket_object.sample_website.key
      }
      output_artifacts = [
        "SourceArtifact"]
    }
  }
  stage {
    name = "Deploy"
    action {
      category        = "Deploy"
      name            = "prod-deploy"
      owner           = "AWS"
      provider        = "S3"
      version         = "1"
      region          = var.prod_region
      role_arn        = aws_iam_role.prod_deploy.arn
      input_artifacts = [
        "SourceArtifact"]
      configuration   = {
        BucketName = aws_s3_bucket.prod.bucket
        Extract    = true
      }
    }
  }
}

