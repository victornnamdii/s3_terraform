 variable "domain_name" {
   
 }

 variable "zone_id" {
   
 }

 variable "alternative_names" {
   type = list(string)
   default = []
 }

 variable "tags" {
   type = map(string)
   default = {}
 }