variable "api_id" {
  description = "The ID of the API Gateway"
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
