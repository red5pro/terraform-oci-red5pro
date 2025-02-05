
output "red5pro_node_image" {
  description = "Stream Manager 2.0 Red5 Pro Node Image (OCI Custom Image)"
  value       = try(oci_core_image.red5pro_node_image.display_name, "")
}
