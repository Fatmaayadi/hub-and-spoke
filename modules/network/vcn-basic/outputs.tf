# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
output "subnets" {
  description = "The subnets, indexed by display_name."
  value       = { for s in oci_core_subnet.these : s.display_name => s }
}
output "internet_gateways" {
  description = "The Internet gateways, indexed by display_name."
  value       = { for g in oci_core_internet_gateway.these : g.vcn_id => g }
}
output "internet_gateway_id" {
  value = { for k, igw in oci_core_internet_gateway.these : k => igw.id }
}

output "nat_gateways" {
  description = "The NAT gateways, indexed by display_name."
  value       = { for g in oci_core_nat_gateway.these : g.vcn_id => g }
}

output "service_gateways" {
  value = { for k, g in oci_core_service_gateway.these : g.vcn_id => g }
}

output "debug_service_gateways" {
  value = oci_core_service_gateway.these
}

output "vcns" {
  value = oci_core_vcn.these
}

output "all_services" {
  description = "All services"
  value       = data.oci_core_services.all_services
}
output "security_lists" {
  description = "All Network Security Lists"
  value       = { for sl in oci_core_security_list.these : sl.display_name => sl }
}
output "vcn_ids" {
  value = { for k, v in oci_core_vcn.these : k => v.id }
}

output "subnet_ids" {
  value = { for k, v in oci_core_subnet.these : k => v.id }
}
