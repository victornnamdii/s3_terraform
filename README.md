# DEPLOY A STATIC WEBSITE ON S3 BUCKET WITH TERRAFORM

This repo contains my solution to the 2nd assignment in my altschhol 3rd semester.

- **Name: Ilodiuba Victor Nnamdi**
- **School: School of Engineering**
- **Track: Cloud Engineering**
- **ID No: ALT/SOE/023/3812**

## Solution

My deployment was divided into 7 sub modules relating to each major AWS service. This was to achieve a clear, maintainable and reliable structure. All 7 modules were then connected to the root module in the `main` directory that passes the necessary variables and gets the required outputs. The 7 sub modules and the root module are explained below:

### s3_bucket

This module is responsible for creating the required S3 bucket and uploading the files contained in the `html` directory which carry the files for the static website. It uploads the files using the `upload_object` resource. It then configures the bucket to use `index.html` and `error.html` as the index and error documents respectively usimg the `ws_s3_bucket_website_configuration` resource. The `aws_s3_bucket_policy` defines and and attaches the policy to the S3 bucket using it's ID and the policy is defined in the `policy` component to allow access for files to be retrieved from the bucket. Then bucket's ARN and endpoint are then outputted for use in the cloudfront and IAM modules.

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
- The cloudfront's domain name and zone id is then outputted for later use.

### iam

This module creates an IAM role and policy that allow our CloudFront distribution to securely access our S3 bucket, using an Origin Access Identity (OAI).

- The `aws_iam_role` resource creates an IAM role that can be assumed by our cloudfront distribution

- `name` specifies the name of the IAM role, here it’s "cloudfront-access-identity-role".
- `assume_role_policy` defines the  policy document that grants the distribution the ability to assume this role.
	- `Action: "sts:AssumeRole"` allows the role to be assumed.
	- `Effect: "Allow"` allows the specified actions.
	- `Principal: { "Service": "cloudfront.amazonaws.com" }` specifies cloudfront as the principal that can assume the role.
- The `aws_iam_role_policy` resource attaches a policy to the previously created IAM role, granting it permissions to access the S3 bucket.
	- `role`: associates the policy with the IAM role created above, using `aws_iam_role.cloudfront_access_identity.id`.
	- `policy` defines the actual permissions.
	- `"s3:GetObject"` allows reading objects from the S3 bucket.
	- `"s3:ListBucket"` allows listing objects within the bucket.
	- `"${var.s3_bucket_arn}/*"` refers to all objects within the S3 bucket, the bucket's ARN is gotten from the outputs from the `s3_bucket` module passed as a variable to the `iam` module.

### route53

This module creates a DNS record in AWS Route 53 for a domain, mapping it to our cloudfront distribution.

- The `aws_route53_record` resource creates a DNS record and pecifies that the resource being managed is a Route 53 DNS record.
    - `zone_id = var.zone_id` specifies the hosted zone in Route 53 where the DNS record will be created. This is passed through the `zone_id` variable which would contain the ID of the route 53 hosted zone.
    - `name = var.domain_name` specifies the name of the DNS record as our domain name through a variable.
    - `type = "A"` specifies that the record is an address record, which maps our domain name to an IP address, in this case would be our cloudfront distribution's IP address.
    - The `alias` block specifies that this DNS record is an alias to another AWS resource, in this case, our cloudfront distribution.
        - `name = var.cloudfront_domain_name` specifies the domain name of the cloudfront distribution to which this alias record would point to.
        - `zone_id = var.cloudfront_zone_id` specifies the hosted zone ID for CloudFront in Route 53. This value is usually constant (Z2FDTNDATAQYW2) as it’s the same for all cloudfront distributions.
        - `evaluate_target_health = false` specifies whether Route 53 should evaluate the health of the target before responding to DNS queries. `false` means Route 53 does not perform health checks on the cloudfront distribution when determining DNS responses.

### certificate

This module sets up an AWS certificate manager certificate for our domain, validates it using DNS, and integrates it with Route 53.

- The `aws_acm_certificate` resource requests an SSL/TLS certificate from AWS certificate manager.
    - `domain_name = var.domain_name` specifies the  domain name for the certificate. Our domain name is passed here through a variable.
    - `validation_method = "DNS"` specifies that the domain validation method for the certificate is DNS. This means AWS certificate manager will generate DNS records that need to be added to the DNS provider to prove domain ownership.
    - `subject_alternative_names = var.alternative_names` specifies any additional domain names  that shoukd be included in the certificate. In our case, an empty list is passed since we do not require alternative domain names
    - `lifecycle { create_before_destroy = true }` ensures that a new certificate is created before the old one is destroyed, to minimize downtime during updates.
    - `tags = var.tags` adds tags to the certificate for organization and management purposes.
- The `aws_route53_record` resource creates DNS records in Route 53 to validate the ACM certificate. It creates multiple DNS records, one for each domain validation option provided by ACM.
	- It uses `aws_acm_certificate.website_certificate.domain_validation_options`, which contains the DNS validation records ACM requires to verify domain ownership.
	- Inside the for_each loop, `name = dvo.resource_record_name` contains name of the DNS record that needs to be added for validation, `type = dvo.resource_record_type` contains the type of DNS record. `value = dvo.resource_record_value` contains the value of the DNS record, `zone_id = var.zone_id` contains the ID of the Route 53 hosted zone where the DNS record should be created.
	- Route 53 Record Configuration:
	    -  `name = each.value.name` sets the name of the DNS record from the for_each map.
	    - `type = each.value.type` sets the type of the DNS record.
	    - `zone_id = each.value.zone_id` specifies the hosted zone ID.
	    - `records = [ each.value.value ]`ets the DNS record value.
	    - `ttl = 300` sets the Time-To-Live for the DNS record to 300 seconds.
- The `aws_acm_certificate_validation` resource completes the validation of the ACM certificate using the Route 53 DNS records created above.
    - `certificate_arn = aws_acm_certificate.website_certificate.arn` specifies the ARN of the ACM certificate to validate.
    - `validation_record_fqdns = [ for record in aws_route53_record.certificate_validation : record.fqdn ]` collects the Fully Qualified Domain Names (FQDNs) of the Route 53 DNS records created for validation. `record.fqdn` refers to the full DNS name of each Route 53 record.

### api_gateway

This module contains two sub modules: `config` and `resources` containing the configuration for the API gateway and it's resources respectively.

#### config

This sub module sets up an AWS API Gateway for a REST API, deploys it, and creates a stage for it.

- The `aws_api_gateway_rest_api` resource creates a new REST API in AWS API Gateway.

    - `name = var.api_name` apecifies the name of the API. var.api_name is a variable containing the desired name for the API Gateway.
	- `description = var.api_description` provides a description for the API. var.api_description is a variable that holds a brief description of the API.
	- `endpoint_configuration { types = ["EDGE"] }` configures the type of endpoint for the API. "EDGE" specifies that the API will be deployed to the cloudfront network for global access which is the default setting.
	- `tags = var.tags` adds tags to the API Gateway for organizational and management purposes.

- The `aws_api_gateway_deployment` resource creates a deployment for the API

	- `depends_on = [aws_api_gateway_rest_api.api]` ensures that the REST API is created before the deployment is executed. This is because a deployment requires a REST API to be in place.
	- `rest_api_id = aws_api_gateway_rest_api.api.id` specifies the ID of the REST API to be deployed. This links the deployment to our previously defined `aws_api_gateway_rest_api` resource.
	- `stage_name = var.stage_name` sets the stage name for the deployment. var.stage_name is a variable that should contain the desired stage name, in my case, i used `development`.
	- `lifecycle { create_before_destroy = true }` ensures that the new deployment is created before the old one is destroyed, to minimize downtime.
	- `description = "Deployment for stage ${var.stage_name}"` provides a description for the deployment, saying it is for my specified stage name

- The `aws_api_gateway_stage` resource creates a stage for the API, associating it with a specific deployment.

	- `deployment_id = aws_api_gateway_deployment.api_deployment.id` specifies the ID of the deployment to be associated with this stage. This links the stage to the deployment defined in `aws_api_gateway_deployment`.
	- `rest_api_id = aws_api_gateway_rest_api.api.id` specifies the ID of the REST API for this stage. This links the stage to the REST API defined in `aws_api_gateway_rest_api`.
	- `stage_name = var.stage_name` sets the name of the stage.

#### resources

This sub module sets up an API Gateway resource with methods and integrations. It defines new resources in the API, adding HTTP methods to these resources, and setting up how these methods interact with backend services.

- The `aws_api_gateway_resource` resource creates a new path in the API Gateway REST API.

	- `rest_api_id = var.api_id` specifies the ID of the REST API in which this resource will be created. var.api_id is a variable containing the API Gateway ID.
	- `parent_id = var.parent_id` defines the parent resource under which the new resource is created.
	- `path_part = var.path_part` represents the path segment for the new resource.

- The `aws_api_gateway_method` resource defines a HTTP method on the created resource.

	- `rest_api_id = var.api_id` links the method to the specified REST API by its ID throught variable `api_id`.
	- `resource_id = aws_api_gateway_resource.resource.id` specifies the resource ID where this method will be added. It sses the ID of the resource created in `aws_api_gateway_resource.resource`.
	- `http_method = var.http_method` sets the HTTP method for the API. In this case "GET" since we're serving a static website. The value is contained in the variable `http_method`
	- `authorization = var.authorization` defines the authorization type for this method. In our case, it is set to "NONE" since our website does not require any authorization.
	- `request_parameters = var.request_parameters` contains optional map of request parameters that can be passed to the method. In this case, i set it to an empty map since i do not require request parameters for my website

