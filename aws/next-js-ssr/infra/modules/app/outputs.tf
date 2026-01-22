output "images_bucket_name" {
  value       = aws_s3_bucket.images.bucket
  description = "画像用バケット名"
}

output "images_bucket_arn" {
  value       = aws_s3_bucket.images.arn
  description = "画像用バケットARN"
}

output "images_bucket_regional_domain_name" {
  value       = aws_s3_bucket.images.bucket_regional_domain_name
  description = "画像用バケットドメイン名"
}
