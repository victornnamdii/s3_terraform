variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "index_document" {
  description = "The index document for the website"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "The error document for the website"
  type        = string
  default     = "error.html"
}

variable "domain_name" {
description = "The domain name for the certificate and DNS"
type        = string
}

variable "alternative_names" {
description = "Alternative domain names for the certificate"
type        = list(string)
default     = []
}

variable "tags" {
description = "Tags to apply to resources"
type        = map(string)
default     = {}
}

variable "create_www_record" {
description = "Boolean to create a CNAME record for the www subdomain"
type        = bool
default     = false
}

variable "additional_records" {
description = "Map of additional DNS records to create"
type        = map(object({
type    = string
ttl     = number
records = list(string)
}))
default = {}
}

variable "api_name" {
description = "The name of the API Gateway"
type        = string
}

variable "api_description" {
description = "The description of the API Gateway"
type        = string
default     = ""
}

variable "api_stage" {
description = "The name of the deployment stage"
type        = string
}

variable "parent_id" {
description = "The parent resource ID for the new resource"
type        = string
}

variable "path_part" {
description = "The path part of the new resource"
type        = string
}

variable "http_method" {
description = "The HTTP method for the resource"
type        = string
}

variable "authorization" {
description = "The authorization type for the method"
type        = string
default     = "NONE"
}

variable "request_parameters" {
description = "The request parameters for the method"
type        = map(bool)
default     = {}
}

variable "integration_uri" {
description = "The URI for the integration"
type        = string
}

variable "request_templates" {
description = "The request templates for the integration"
type        = map(string)
default     = {}
}

variable "region" {
  
}

variable "additional_methods" {
  description = "Map of additional methods to create with their configurations"
  type        = map(object({
    authorization     = string
    request_parameters = map(bool)
    integration_uri    = string
    request_templates  = map(string)
  }))
  default = {}
}

variable "access_key" {
  
}

variable "secret_key" {
  
}
