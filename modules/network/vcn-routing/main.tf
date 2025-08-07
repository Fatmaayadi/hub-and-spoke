# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

### Route tables
resource "oci_core_route_table" "these" {
  for_each       = var.subnets_route_tables
  display_name   = each.key
  vcn_id         = each.value.vcn_id
  compartment_id = var.compartment_id
  defined_tags   = each.value.defined_tags
  freeform_tags  = each.value.freeform_tags

  dynamic "route_rules" {
  iterator = rule

  for_each = concat(
    # Route 0.0.0.0/0 to Internet Gateway (if present)
    (
      lookup(var.internet_gateway_id, each.value.vcn_id, null) != null
      ? [{
          dst               = "0.0.0.0/0"
          dst_type          = "CIDR_BLOCK"
          network_entity_id = lookup(var.internet_gateway_id, each.value.vcn_id)
          description       = "Route to Internet Gateway"
        }]
      : []
    ),

    # Route only to Object Storage service via Service Gateway
    (
      lookup(var.service_gateway_id, each.value.vcn_id, null) != null
      ? [{
          dst               = "all-eu-paris-1-objectstorage"
          dst_type          = "SERVICE_CIDR_BLOCK"
          network_entity_id = lookup(var.service_gateway_id, each.value.vcn_id)
          description       = "Route to Object Storage via Service Gateway"
        }]
      : []
    ),

    # Include other custom routes, but **exclude** the all-services route to SGW
    [
      for r in each.value.route_rules : {
        dst               = try(r.destination, null)
        dst_type          = try(r.destination_type, null)
        network_entity_id = try(r.network_entity_id, null)
        description       = try(r.description, null)
      }
      if try(r.is_create, false) &&
         try(r.network_entity_id, null) != null &&
         !(r.destination == "all-eu-paris-1-services-in-oracle-services-network" &&
           r.network_entity_id == lookup(var.service_gateway_id, each.value.vcn_id, ""))
    ]
  )

  content {
    destination        = rule.value.dst
    destination_type   = rule.value.dst_type
    network_entity_id  = rule.value.network_entity_id
    description        = rule.value.description
  }
}
}

### Route Table Attachments
resource "oci_core_route_table_attachment" "these" {
  for_each       = var.subnets_route_tables
  subnet_id      = each.value.subnet_id
  route_table_id = oci_core_route_table.these[each.key].id
}

