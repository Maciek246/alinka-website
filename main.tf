provider "aws" {
  region  = "${var.aws_region}"
  profile = "default"
}

terraform {
  backend "s3" {}
}

resource "aws_s3_bucket" "alinka_bucket" {
  bucket = "alinka-terraform"
  website = {
    index_document = "index.html"
    error_document = "index.html"
  }

  policy =<<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
  "Sid":"PublicReadForGetBucketObjects",
  "Effect":"Allow",
  "Principal": "*",
  "Action":["s3:GetObject"],
  "Resource":["arn:aws:s3:::alinka-terraform/*"]
  }]
}
  POLICY
}

resource "null_resource" "alinka_build" {
  
  provisioner "local-exec" {
    command = "npm run build"
  }
  
  triggers {
    uuid = "${uuid()}"
  }
}

resource "null_resource" "alinka_dist_sync" {
  
  provisioner "local-exec" {
    command = "aws s3 sync build/ s3://${aws_s3_bucket.alinka_bucket.bucket}"
  }

  triggers {
    uuid = "${uuid()}"
  }

  depends_on = ["null_resource.alinka_build"]
}

resource "aws_cloudfront_distribution" "alinka_cloudfront_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.alinka_bucket.bucket_regional_domain_name}"
    origin_id = "alinka-website-default-origin"
  }

  enabled = true
  is_ipv6_enabled = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "alinka-website-default-origin"
    viewer_protocol_policy = "allow-all"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
