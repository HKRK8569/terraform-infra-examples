resource "aws_s3_bucket" "images" {
  bucket = "${var.name_prefix}-images"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-bucket-images"
  })
}

resource "aws_s3_bucket_public_access_block" "images" {
  bucket = aws_s3_bucket.example.id

  # publicにできないように設定
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
