##### bucket to host static assets
resource "aws_s3_bucket" "this-bucket" {
  bucket = "static-assets-behaviour"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }

  # Permission for own account
  grant {
    id = data.aws_canonical_user_id.account.id
    permissions = [
      "FULL_CONTROL",
    ]
    type = "CanonicalUser"
  }
}

resource "aws_s3_bucket" "public-code-bucket" {
  bucket = "code-bucket-to-download"
  acl    = "public-read"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }
}

data "template_file" "static" {
  template = file("${path.module}/files/policy.tpl")
  vars = {
    principal_arn                  = data.aws_caller_identity.account.arn
    bucket_name                    = aws_s3_bucket.this-bucket.id
    OAI_ID                         = aws_cloudfront_origin_access_identity.this.id
  }
}

resource "aws_s3_bucket_object" "zip_files" {
  bucket   = aws_s3_bucket.public-code-bucket.id
  key      = "app/app.zip"
  source   = "${path.module}/../app/app.zip"
  etag     = filemd5("${path.module}/../app/app.zip")
}

resource "aws_s3_bucket_policy" "assets" {
  bucket = aws_s3_bucket.this-bucket.id
  policy = data.template_file.static.rendered
}

resource "aws_s3_bucket_object" "jsss" {
  for_each = fileset("${path.module}/files/assets/js/", "*")
  bucket   = aws_s3_bucket.this-bucket.id
  key      = "assets/js/${each.value}"
  source   = "${path.module}/files/assets/js/${each.value}"
  etag     = filemd5("${path.module}/files/assets/js/${each.value}")
}

resource "aws_s3_bucket_object" "csss" {
  for_each = fileset("${path.module}/files/assets/css/", "*")
  bucket   = aws_s3_bucket.this-bucket.id
  key      = "assets/css/${each.value}"
  source   = "${path.module}/files/assets/css/${each.value}"
  etag     = filemd5("${path.module}/files/assets/css/${each.value}")
}
