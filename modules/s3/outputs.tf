output "bucket_arn" {
  description = "ARN des S3-Buckets"
  value       = aws_s3_bucket.this.arn
}

output "bucket_name" {
  description = "Name des S3-Buckets"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_id" {
  description = "ID des S3-Buckets"
  value       = aws_s3_bucket.this.id
}

output "bucket_domain_name" {
  description = "Domain-Name des S3-Buckets"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional Domain-Name des S3-Buckets"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}
