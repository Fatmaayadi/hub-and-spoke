# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "drg" {
  description = "DRG information."
  value       = length(oci_core_drg.this) > 0 ? oci_core_drg.this[0] : null
}

#drg outpus its id  for  fcvc
output "drg_id" {
  description = "OCID of the created DRG"
  value       = length(oci_core_drg.this) > 0 ? oci_core_drg.this[0].id : null
}