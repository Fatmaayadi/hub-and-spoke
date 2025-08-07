# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


#Terraform block to define  which provider we should use , Not recommanded to  change


terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

#defining the ressource block  that we will use  ( used  oci-identity access management ressource type )
resource "oci_identity_compartment" "these" {
  for_each = var.compartments # iterrate to create a compartement for  each iterration by specifiying its  variables 
    compartment_id = each.value.parent_id
    name           = each.value.name
    description    = each.value.description
    enable_delete  = each.value.enable_delete
    defined_tags   = each.value.defined_tags
    freeform_tags  = each.value.freeform_tags
}