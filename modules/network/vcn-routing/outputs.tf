# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "subnets_route_tables" {
  description = "The managed subnets_route tables, indexed by display_name."
  value = {
    for rt in oci_core_route_table.these : 
      rt.display_name => rt
    }
}
output "debug_route_rules" {
  value = var.subnets_route_tables
}
output "debug_all_route_rules" {
  value = {
    for subnet_key, subnet_val in var.subnets_route_tables :
    subnet_key => [
      for r in subnet_val.route_rules :
      {
        destination        = r.destination
        destination_type   = r.destination_type
        network_entity_id  = r.network_entity_id
        description       = r.description
      }
    ]
  }
}
