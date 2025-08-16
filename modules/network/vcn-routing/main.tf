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
      "${name}-igw" => {
        name           = "${name}-igw"
        vcn_id         = cfg.vcn_id
        compartment_id = cfg.compartment_id
        defined_tags   = cfg.defined_tags
        freeform_tags  = cfg.freeform_tags
        subnet_id      = cfg.subnet_id
        route_rules    = [for r in cfg.route_rules : r if try(r.destination, null) == "0.0.0.0/0"]
      }
      if anytrue([for r in cfg.route_rules : try(r.destination, null) == "0.0.0.0/0"])
    },
    {
      for name, cfg in var.subnets_route_tables :
      "${name}-sgw" => {
        name           = "${name}-sgw"
        vcn_id         = cfg.vcn_id
        compartment_id = cfg.compartment_id
        defined_tags   = cfg.defined_tags
        freeform_tags  = cfg.freeform_tags
        subnet_id      = cfg.subnet_id
        route_rules    = [for r in cfg.route_rules : r if try(r.destination, null) == "all-eu-paris-1-services-in-oracle-services-network"]
      }
      if anytrue([for r in cfg.route_rules : try(r.destination, null) == "all-eu-paris-1-services-in-oracle-services-network"])
    }
  )

  subnet_route_table_attachments = {
    for k, v in local.subnets_route_tables_split :
    k => v.subnet_id
  }
}

resource "oci_core_route_table" "these" {
  for_each       = local.subnets_route_tables_split
  display_name   = each.value.name
  vcn_id         = each.value.vcn_id
  compartment_id = each.value.compartment_id
  defined_tags   = each.value.defined_tags
  freeform_tags  = each.value.freeform_tags

  dynamic "route_rules" {
    iterator = rule
    for_each = each.value.route_rules

    content {
      destination        = rule.destination
      destination_type   = rule.destination_type
      network_entity_id  = rule.network_entity_id
      description        = rule.description
    }
  }
}

resource "oci_core_route_table_attachment" "these" {
  for_each = local.subnet_route_table_attachments

  subnet_id      = each.value
  route_table_id = oci_core_route_table.these[each.key].id
}
