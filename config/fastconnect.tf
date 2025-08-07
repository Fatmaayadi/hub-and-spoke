


module "fastconnect" {
  source = "./modules/network/fastconnect"

  compartment_id          = var.network_compartment_id
  service_label           = "oci-gcp-interconnect"
  customer_asn            = 65000  # Use your actual ASN 2 value
  drg_id                  = module.drg.drg_id
  
  # For VLAN Attachment 1
  customer_bgp_peering_ip_1 = "169.254.0.2/30"  # Adjust based on your IP addressing plan
  oracle_bgp_peering_ip_1   = "169.254.0.1/30"
  vlan_id_1                 = 100
  provider_service_key_name_1 = "gcp-service-key-1"  # This is provided by GCP
  
  # For VLAN Attachment 2
  customer_bgp_peering_ip_2 = "169.254.0.6/30"  # Adjust based on your IP addressing plan
  oracle_bgp_peering_ip_2   = "169.254.0.5/30"
  vlan_id_2                 = 200
  provider_service_key_name_2 = "gcp-service-key-2"  # This is provided by GCP
  
  # If we already know the provider service ID (recommended)
  is_create_provider_service = false
  provider_service_id        = "ocid1.providerservice.oc1...specific-to-gcp-interconnect" #we need actual provider id here 
  
  # For BGP security (optional)
  bgp_md5auth_key            = var.bgp_md5auth_key
}