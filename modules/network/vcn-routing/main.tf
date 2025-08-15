# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}
locals {
  subnets_route_tables_split = merge(
    {
      for name, cfg in var.subnets_route_tables :
      "${name}-igw" => merge(cfg, {
        route_rules = [
          for r in cfg.route_rules :
          r if try(r.destination, null) == "0.0.0.0/0"
        ]
      })
      if anytrue([
        for r in cfg.route_rules : try(r.destination, null) == "0.0.0.0/0"
      ])
    },
    {
      for name, cfg in var.subnets_route_tables :
      "${name}-sgw" => merge(cfg, {
        route_rules = [
          for r in cfg.route_rules :
          r if try(r.destination, null) == "all-eu-paris-1-services-in-oracle-services-network"
        ]
      })
      if anytrue([
        for r in cfg.route_rules : try(r.destination, null) == "all-eu-paris-1-services-in-oracle-services-network"
      ])
    }
  )
}


resource "oci_core_route_table" "these" {
  for_each       = local.subnets_route_tables_split
  display_name   = each.key
  vcn_id         = each.value.vcn_id
  compartment_id = each.value.compartment_id
  defined_tags   = each.value.defined_tags
  freeform_tags  = each.value.freeform_tags

  dynamic "route_rules" {
    iterator = rule

    for_each = [
      for r in each.value.route_rules : {
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

### Route Table Attachments
resource "oci_core_route_table_attachment" "these" {
  for_each       = var.subnets_route_tables
  subnet_id      = each.value.subnet_id
  route_table_id = oci_core_route_table.these[each.key].id
}

