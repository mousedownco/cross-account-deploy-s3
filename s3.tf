resource aws_s3_bucket source {
  provider = aws.tools
  bucket   = "source-${var.tools_account_number}-${var.tools_region}"
  versioning {
    enabled = true
  }
}
resource aws_s3_bucket_public_access_block source {
  provider                = aws.tools
  bucket                  = aws_s3_bucket.source.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource aws_s3_bucket_object sample_website {
  provider = aws.tools
  bucket   = aws_s3_bucket.source.bucket
  key      = "sample-website.zip"
  source   = "sample-website.zip"
}

resource aws_s3_bucket pipeline_artifacts {
  provider = aws.tools
  bucket   = "codepipeline-${var.tools_account_number}-${var.tools_region}"
}
resource aws_s3_bucket_public_access_block pipeline_artifacts {
  provider                = aws.tools
  bucket                  = aws_s3_bucket.pipeline_artifacts.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
data aws_iam_policy_document prod_artifact_access {
  statement {
    actions   = [
      "s3:Get*"]
    resources = [
      "${aws_s3_bucket.pipeline_artifacts.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [
        var.prod_account_number]
    }
  }
  statement {
    actions   = [
      "s3:ListBucket"]
    resources = [
      aws_s3_bucket.pipeline_artifacts.arn]
    principals {
      type        = "AWS"
      identifiers = [
        var.prod_account_number]
    }
  }
}
resource aws_s3_bucket_policy prod_artifact_access {
  provider = aws.tools
  bucket   = aws_s3_bucket.pipeline_artifacts.bucket
  policy   = data.aws_iam_policy_document.prod_artifact_access.json
}

resource aws_s3_bucket prod {
  provider = aws.prod
  bucket   = "production-${var.prod_account_number}-${var.prod_region}"
}
resource aws_s3_bucket_public_access_block prod {
  provider                = aws.prod
  bucket                  = aws_s3_bucket.prod.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
