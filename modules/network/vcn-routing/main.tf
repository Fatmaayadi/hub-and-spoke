terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

locals {
  # Création de tables IGW et SGW avec des clés statiques
  route_table_definitions = merge(
    {
      for name, cfg in var.subnets_route_tables :
      "${name}-igw" => {
        display_name   = "${name}-igw"
        vcn_id         = cfg.vcn_id
        compartment_id = cfg.compartment_id
        defined_tags   = cfg.defined_tags
        freeform_tags  = cfg.freeform_tags
        route_rules    = [for r in cfg.route_rules : r if try(r.destination, null) == "0.0.0.0/0"]
      }
      if anytrue([for r in cfg.route_rules : try(r.destination, null) == "0.0.0.0/0"])
    },
    {
      for name, cfg in var.subnets_route_tables :
      "${name}-sgw" => {
        display_name   = "${name}-sgw"
        vcn_id         = cfg.vcn_id
        compartment_id = cfg.compartment_id
        defined_tags   = cfg.defined_tags
        freeform_tags  = cfg.freeform_tags
        route_rules    = [for r in cfg.route_rules : r if try(r.destination, null) == "all-eu-paris-1-services-in-oracle-services-network"]
      }
      if anytrue([for r in cfg.route_rules : try(r.destination, null) == "all-eu-paris-1-services-in-oracle-services-network"])
    }
  )
}

resource "oci_core_route_table" "these" {
  for_each       = local.route_table_definitions
  display_name   = each.value.display_name
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
