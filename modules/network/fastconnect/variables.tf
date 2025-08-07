
variable "tenancy_ocid" {
  description = "OCID of your tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the user"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the API key"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private key"
  type        = string
}

variable "region" {
  description = "OCI region"
  type        = string
}
variable "compartment_id" {
  description = "OCID of the compartment where the FastConnect resources will be created"
  type        = string
}

variable "service_label" {
  description = "Unique label to identify all related resources"
  type        = string
}

variable "customer_asn" {
  description = "Customer ASN (Autonomous System Number) for BGP session, should be ASN 2 as per diagram"
  type        = number
  default     = 65000
}

variable "drg_id" {
  description = "OCID of the Dynamic Routing Gateway to connect FastConnect to"
  type        = string
}

variable "is_create_provider_service" {
  description = "Whether to create a new provider service or use an existing one"
  type        = bool
  default     = false
}

variable "provider_service_id" {
  description = "OCID of existing provider service if is_create_provider_service is false"
  type        = string
  default     = ""
}

# VLAN Attachment 1 variables
variable "customer_bgp_peering_ip_1" {
  description = "Customer BGP peering IP for VLAN Attachment 1"
  type        = string
  default     = "169.254.0.2/30"
}

variable "oracle_bgp_peering_ip_1" {
  description = "Oracle BGP peering IP for VLAN Attachment 1"
  type        = string
  default     = "169.254.0.1/30"
}

variable "vlan_id_1" {
  description = "VLAN ID for Attachment 1"
  type        = number
  default     = 100
}

variable "provider_service_key_name_1" {
  description = "Provider service key for VLAN Attachment 1 (provided by GCP)"
  type        = string
  default     = ""
}

# VLAN Attachment 2 variables
variable "customer_bgp_peering_ip_2" {
  description = "Customer BGP peering IP for VLAN Attachment 2"
  type        = string
  default     = "169.254.0.6/30"
}

variable "oracle_bgp_peering_ip_2" {
  description = "Oracle BGP peering IP for VLAN Attachment 2"
  type        = string
  default     = "169.254.0.5/30"
}

variable "vlan_id_2" {
  description = "VLAN ID for Attachment 2"
  type        = number
  default     = 200
}

variable "provider_service_key_name_2" {
  description = "Provider service key for VLAN Attachment 2 (provided by GCP)"
  type        = string
  default     = ""
}

# Common variables
variable "bgp_md5auth_key" {
  description = "BGP MD5 authentication key"
  type        = string
  default     = null
  sensitive   = true
}

variable "is_create_drg_route_table" {
  description = "Whether to create a new DRG route table"
  type        = bool
  default     = true
}

variable "import_drg_route_distribution_id" {
  description = "OCID of DRG route distribution to import"
  type        = string
  default     = null
}

variable "defined_tags" {
  description = "Defined tags for resources"
  type        = map(string)
  default     = {}
}

variable "freeform_tags" {
  description = "Freeform tags for resources"
  type        = map(string)
  default     = {}
}