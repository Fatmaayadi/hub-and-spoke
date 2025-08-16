# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

# No dynamic locals needed for for_each
# We will use var.subnets_route_tables directly

resource "oci_core_route_table" "these" {
  for_each       = var.subnets_route_tables

  display_name   = each.key
  vcn_id         = each.value.vcn_id
  compartment_id = each.value.compartment_id
  defined_tags   = each.value.defined_tags
  freeform_tags  = each.value.freeform_tags

  dynamic "route_rules" {
    iterator = rule
    for_each = [
      for r in each.value.route_rules :
      {
        dst               = try(r.destination, null)
        dst_type          = try(r.destination_type, null)
        network_entity_id = try(r.network_entity_id, null)
        description       = try(r.description, null)
      }
      if try(r.is_create, false) && try(r.network_entity_id, null) != null
    ]

    content {
      destination        = rule.value.dst
      destination_type   = rule.value.dst_type
      network_entity_id  = rule.value.network_entity_id
      description        = rule.value.description
    }
  }
}

resource "oci_core_route_table_attachment" "these" {
  for_each = var.subnets_route_tables

  subnet_id      = each.value.subnet_id
  route_table_id = oci_core_route_table.these[each.key].id
}
