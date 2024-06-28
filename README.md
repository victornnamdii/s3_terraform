# DEPLOY A STATIC WEBSITE ON S3 BUCKET WITH TERRAFORM

This repo contains my solution to the 2nd assignment in my altschhol 3rd semester.

- **Name: Ilodiuba Victor Nnamdi**
- **School: School of Engineering**
- **Track: Cloud Engineering**
- **ID No: ALT/SOE/023/3812**

## Solution

My deployment was divided into 6 sub modules relating to each major AWS service. This was to achieve a clear, maintainable and reliable structure. All 6 modules were then connected to the root module in the `main` directory that passes the necessary variables and gets the required outputs. The 6 sub modules are explained below:

### s3_bucket

This module is responsible for creating the required S3 bucket and uploading the files contained in the `html` directory which carry the files for the static website. It uploads the files using the `upload_object` resource. It then configures the bucket to use `index.html` and `error.html` as the index and error documents respectively usimg the `ws_s3_bucket_website_configuration` resource. The `aws_s3_bucket_policy` defines and and attaches the policy to the S3 bucket using it's ID and the policy is defined in the `policy` component to allow access for files to be retrieved from the bucket. Then bucket's arn and endpoint are then outputted for use in the cloudfront and IAM modules.

### cloudfront

- The `locals` block defines a local value s3_origin_id which would be used later for cloudfront's originidentification configuration.
- The `aws_cloudfront_distribution` resource then creates and configures a cloudfront configuration, using the initially created S3 bucket as the origin. The cloudfront's origin domain name would be set as the bucket's `website_endpoint` which was outputted after the bucket's creation.
- `s3_origin_config` configures the S3 bucket as the origin and associates it with a cloudfront origin access identity that allows our cloudfront distribution access to the S3 bucket. `aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path` provides the path to the OAI created.
- `enabled` enables the cloudfront distribution, `is_ipv6_enabled` enables IPv6 support for the distribution, `default_root_object` sets the default root object as our previously uploaded  `index.html`
- `default_cache_behavior` helps define how our distribution should handle requests. `allowed_methods` specifies which HTTP methods the distribution should allow and since we are serving static content, GET and HEAD methods are sufficient. `cached_methods` specifies which HTTP methods are cached. The same values ad `allowed_methods` are used here. `target_origin_id` points to the origin by its ID, linking it to `local.s3_origin_id`. `forwarded_values` configures how CloudFront handles query strings and cookies. `query_string = false` means query strings are not forwarded to the origin as it is not required for our website. `cookies { forward = "none" }` means no cookies are forwarded, as it is also not required. `viewer_protocol_policy` ensures all requests are redirected to HTTPS, for secure commmunication. `min_ttl, default_ttl, max_ttl` control the caching time-to-live (TTL) values. They define the minimum, default, and maximum TTLs for cached objects, respectively:
    - min_ttl = 0: No minimum TTL.
    - default_ttl = 3600: Default TTL of 1 hour.
    - max_ttl = 86400: Maximum TTL of 1 day.
- `restrictions { geo_restrcition { restriction_type = "none"} }` ensures that no geographic restrictions are set on content delivery
- `price_class = "PriceClass_100"` sets the distribution to use the least expensive configuration
- The `aws_cloudfront_origin_access_identity` creates an OAI for the distribution for access to the S3 bucket while preventing direct public access.
- The cloudfront's domain name is then outputted for later use.


