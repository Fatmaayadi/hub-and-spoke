# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  description = "Compartment OCID."
  type        = string
}

variable "subnets_route_tables" {
  description = "Subnet Route Tables"
  type        = map(object({
    compartment_id    = string,
    vcn_id            = string,
    defined_tags      = map(string),
    freeform_tags     = map(string),
    subnet_id         = string,
    route_rules = list(object({
      is_create         = bool
      destination       = string
      destination_type  = string
      network_entity_id = string
      description       = string
    }))
  }))  
}
variable "vcn_id" {
  description = "VCN OCID to which the route tables will be attached."
  type        = string
  default     = null
}
variable "internet_gateway_id" {
  type = map(string)
  description = "Map of internet gateway IDs keyed by subnet or route table name"
}
variable "service_gateway_id" {
  description = "Map of VCN ID to Service Gateway OCID"
  type        = map(string)
  default     = {}
}

