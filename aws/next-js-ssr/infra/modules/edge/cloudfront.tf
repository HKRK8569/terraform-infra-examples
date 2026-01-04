resource "aws_cloudfront_origin_access_control" "images" {
  name                              = "${var.name_prefix}-images-oac"
  description                       = "画像は署名付きURL経由でアクセスを行う"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"

}

# キャッシュ無効
data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

# キャッシュ最適化
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

# ssr用のキャッシュ設定
resource "aws_cloudfront_cache_policy" "ssr_cache" {
  name        = "${var.name_prefix}-ssr-cache"
  comment     = "SSRはデフォルトでキャッシュする"
  min_ttl     = 0
  default_ttl = 60
  max_ttl     = 3600

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Accept", "Host"]
      }
    }

    query_strings_config {
      query_string_behavior = "all"
    }

    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true
  }
}

# 全て許可
data "aws_cloudfront_origin_request_policy" "all_viewer" {
  name = "Managed-AllViewer"
}

resource "aws_cloudfront_origin_request_policy" "ssr_public" {
  name    = "${var.name_prefix}-ssr-public"
  comment = "SSR用のリクエストポリシー"

  # cookieは送らない
  cookies_config {
    cookie_behavior = "none"
  }

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Accept", "Host"]
    }
  }

  # queryStringsは全て許可
  query_strings_config {
    query_string_behavior = "all"
  }
}



resource "aws_cloudfront_distribution" "this" {
  enabled         = true
  is_ipv6_enabled = true



  # cloudFrontからS3へ接続(/images)
  origin {
    domain_name              = aws_s3_bucket.images.bucket_regional_domain_name
    origin_id                = "s3-image-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.images_oac.id
  }
  # CloudFrontからALBへHTTPで接続(デフォルト)
  origin {
    domain_name = aws_lb.this.dns_name
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }



  # imagesはS3に飛ばす
  ordered_cache_behavior {
    path_pattern           = "/images/*"
    target_origin_id       = "s3-images-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]


    cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  # /apiはキャッシュをせずに接続
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    # /apiはキャッシュしない
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer.id
  }

  # その他はデフォルトでキャッシュを行う
  default_cache_behavior {
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    # キャッシュを行う
    cache_policy_id          = aws_cloudfront_cache_policy.ssr_cache.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.ssr_public.id
  }


  # cloudFrontデフォルトのドメインを利用する
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cloudfront"
  })
}
