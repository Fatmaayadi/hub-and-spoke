

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# FastConnect Provider Service (Cross-Cloud Interconnect with GCP), but im not sure yet  with this.
#data "oci_core_fast_connect_provider_service" "gcp_interconnect" {
 # count            = var.is_create_provider_service ? 1 : 0
  #type             = "LAYER2"  # Using Layer2 for BGP control as shown in the diagram
  #provider_name    = "Google Cloud Platform"
  #provider_service_name = "Partner Cross-Cloud Connect"
#}


# Virtual Circuit for VLAN Attachment 1 (1Gbps)
resource "oci_core_virtual_circuit" "vlan_attachment_1" {
  compartment_id            = var.compartment_id
  type                      = "PRIVATE"
  bandwidth_shape_name      = "1 Gbps"
  display_name              = "${var.service_label}-vlan-attachment-1" #i can add it directly
  
  cross_connect_mappings {
    bgp_md5auth_key         = var.bgp_md5auth_key
    customer_bgp_peering_ip = var.customer_bgp_peering_ip_1
    oracle_bgp_peering_ip   = var.oracle_bgp_peering_ip_1
    vlan                    = var.vlan_id_1
  }
  
  customer_asn              = var.customer_asn  # ASN 2 as shown in diagram
  gateway_id                = var.drg_id        # Connect to DRG
  #flexibility , which means we can create a new provider id or use and existing one 
  #provider_service_id       = var.is_create_provider_service ? oci_core_fast_connect_provider_service.gcp_interconnect[0].id : var.provider_service_id
  provider_service_id       = var.provider_service_id
  provider_service_key_name = var.provider_service_key_name_1
  
  defined_tags              = var.defined_tags
  freeform_tags             = merge(var.freeform_tags, {
    "VLANAttachment" = "1"
    "Purpose" = "OCI-GCP-CrossCloud"
  })
}

# Virtual Circuit for VLAN Attachment 2 (1Gbps) - Redundant connection
resource "oci_core_virtual_circuit" "vlan_attachment_2" {
  compartment_id            = var.compartment_id
  type                      = "PRIVATE" 
  bandwidth_shape_name      = "1 Gbps"
  display_name              = "${var.service_label}-vlan-attachment-2"
  
  cross_connect_mappings {
    bgp_md5auth_key         = var.bgp_md5auth_key
    customer_bgp_peering_ip = var.customer_bgp_peering_ip_2
    oracle_bgp_peering_ip   = var.oracle_bgp_peering_ip_2
    vlan                    = var.vlan_id_2
  }
  
  customer_asn              = var.customer_asn  # ASN 2 as shown in diagram
  gateway_id                = var.drg_id        # Connect to DRG
  #provider_service_id       = var.is_create_provider_service ? oci_core_fast_connect_provider_service.gcp_interconnect[0].id : var.provider_service_id
  provider_service_id       = var.provider_service_id
  provider_service_key_name = var.provider_service_key_name_2
  
  defined_tags              = var.defined_tags
  freeform_tags             = merge(var.freeform_tags, {
    "VLANAttachment" = "2"
    "Purpose" = "OCI-GCP-CrossCloud"
  })
}

# BGP Session Configuration - Can be expanded if needed
resource "oci_core_drg_route_table" "bgp_route_table" {
  count                     = var.is_create_drg_route_table ? 1 : 0
  drg_id                    = var.drg_id
  display_name              = "${var.service_label}-bgp-route-table"
  import_drg_route_distribution_id = var.import_drg_route_distribution_id
  
  defined_tags              = var.defined_tags
  freeform_tags             = var.freeform_tags
}
######    we will verify the section below later after   successfully we create the virtual circuit ressource 


# Associate Virtual Circuits with DRG Route Table
# resource "oci_core_drg_attachment_management" "vlan_attachment_1_management" {
 # compartment_id            = var.compartment_id # required
 # count                     = var.is_create_drg_route_table ? 1 : 0
 # attachment_type           = "VIRTUAL_CIRCUIT"
 # drg_id                    = var.drg_id
 # display_name              = "${var.service_label}-vlan1-drg-attachment"
 # drg_route_table_id        = oci_core_drg_route_table.bgp_route_table[0].id
 # network_id                = oci_core_virtual_circuit.vlan_attachment_1.id
#}

#resource "oci_core_drg_attachment_management" "vlan_attachment_2_management" {
#  compartment_id            = var.compartment_id
#  count                     = var.is_create_drg_route_table ? 1 : 0
#  attachment_type           = "VIRTUAL_CIRCUIT"
#  drg_id                    = var.drg_id
#  display_name              = "${var.service_label}-vlan2-drg-attachment"
#  drg_route_table_id        = oci_core_drg_route_table.bgp_route_table[0].id
#  network_id                = oci_core_virtual_circuit.vlan_attachment_2.id
#}