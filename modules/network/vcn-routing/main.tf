terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

locals {
  # Split route tables into IGW and SGW
  igw_route_tables = {
    for name, cfg in var.subnets_route_tables :
    "${name}-igw" => {
      subnet_id      = cfg.subnet_id
      vcn_id         = cfg.vcn_id
      compartment_id = cfg.compartment_id
      defined_tags   = cfg.defined_tags
      freeform_tags  = cfg.freeform_tags
      route_rules = [
        for r in cfg.route_rules :
        r if try(r.destination, null) == "0.0.0.0/0"
      ]
    }
    if anytrue([
      for r in cfg.route_rules : try(r.destination, null) == "0.0.0.0/0"
    ])
  }

  sgw_route_tables = {
    for name, cfg in var.subnets_route_tables :
    "${name}-sgw" => {
      subnet_id      = cfg.subnet_id
      vcn_id         = cfg.vcn_id
      compartment_id = cfg.compartment_id
      defined_tags   = cfg.defined_tags
      freeform_tags  = cfg.freeform_tags
      route_rules = [
        for r in cfg.route_rules :
        r if try(r.destination, null) == "all-eu-paris-1-services-in-oracle-services-network"
      ]
    }
    if anytrue([
      for r in cfg.route_rules : try(r.destination, null) == "all-eu-paris-1-services-in-oracle-services-network"
    ])
  }

  all_route_tables = merge(local.igw_route_tables, local.sgw_route_tables)

  subnet_route_table_attachments = {
    for name, cfg in local.all_route_tables :
    cfg.subnet_id => name
  }
}

resource "oci_core_route_table" "these" {
  for_each       = local.all_route_tables

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
  for_each = local.subnet_route_table_attachments

  subnet_id      = each.key
  route_table_id = oci_core_route_table.these[each.value].id
}
