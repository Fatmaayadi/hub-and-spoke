

output "vlan_attachment_1_id" {
  description = "OCID of the first VLAN attachment virtual circuit"
  value       = oci_core_virtual_circuit.vlan_attachment_1.id
}

output "vlan_attachment_2_id" {
  description = "OCID of the second VLAN attachment virtual circuit"
  value       = oci_core_virtual_circuit.vlan_attachment_2.id
}

output "bgp_route_table_id" {
  description = "OCID of the BGP route table"
  value       = var.is_create_drg_route_table ? oci_core_drg_route_table.bgp_route_table[0].id : null
}

#output "provider_service_id" {
 # description = "OCID of the FastConnect provider service"
  #value       = var.is_create_provider_service ? oci_core_fast_connect_provider_service.gcp_interconnect[0].id : var.provider_service_id
#}

output "bgp_status_vlan_1" {
  description = "BGP session status for VLAN attachment 1"
  value       = oci_core_virtual_circuit.vlan_attachment_1.bgp_session_state
}

output "bgp_status_vlan_2" {
  description = "BGP session status for VLAN attachment 2"
  value       = oci_core_virtual_circuit.vlan_attachment_2.bgp_session_state
}
