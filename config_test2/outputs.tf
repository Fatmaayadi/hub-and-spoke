output "debug_subnet_ids" {
  value = module.lz_vcn_spokes.subnet_ids
}

output "debug_vcn_ids" {
  value = module.lz_vcn_spokes.vcn_ids
}

output "subnet_id_keys" {
  value = keys(module.lz_vcn_spokes.subnet_ids)
}

output "vcn_id_keys" {
  value = keys(module.lz_vcn_spokes.vcn_ids)
}

