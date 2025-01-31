# Red5 Pro common configurations
variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
  validation {
    condition     = length(var.name) > 0
    error_message = "The name value must be a valid! Example: example-name"
  }
}

variable "node_image_display_name" {
  description = "Name of the image in OCI"
  type        = string
}

variable "ssh_private_key" {
  description = "SSH private key to use"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key to use"
  type        = string
}

variable "path_to_red5pro_build" {
  description = "Path to the Red5 Pro build zip file, absolute path or relative path. https://account.red5.net/downloads. Example: /home/ubuntu/terraform-oci-red5pro/red5pro-server-0.0.0.b0-release.zip"
  type        = string
  default     = ""
  validation {
    condition     = fileexists(var.path_to_red5pro_build) == true
    error_message = "The path_to_red5pro_build value must be a valid! Example: /home/ubuntu/terraform-oci-red5pro/red5pro-server-0.0.0.b0-release.zip"
  }
}

variable "red5pro_license_key" {
  description = "Red5 Pro license key (https://www.red5.net/docs/installation/installation/license-key/)"
  type        = string
  default     = ""
}
variable "red5pro_api_enable" {
  description = "Red5 Pro Server API enable/disable (https://www.red5.net/docs/development/api/overview/)"
  type        = bool
  default     = true
}
variable "red5pro_api_key" {
  description = "Red5 Pro Standalone server API key"
  type        = string
  default     = ""
}

variable "node_image_instance_type" {
  description = "Node image - instance type"
  type        = string
  default     = "VM.Standard.E4.Flex"
}
variable "node_image_instance_ocpu" {
  description = "Node image - instance cpu"
  type        = number
  default     = 2
}
variable "node_image_instance_memory" {
  description = "Node image - instance memory"
  type        = number
  default     = 4
}
variable "node_image_instance_volume_size" {
  description = "Volume size in GB for Node image"
  type        = number
  default     = 50
  validation {
    condition     = var.node_image_instance_volume_size >= 50
    error_message = "The node_image_instance_volume_size value must be a valid! Minimum 50"
  }
}

variable "subnet_id" {
  description = "VCN subnet id"
  type        = string
}

variable "red5pro_node_network_security_group_id" {
  type        = string
}

# Oracle Cloud Prvider basic configuration settings
variable "oracle_compartment_id" {
  description = "Oracle Cloud Compartment OCID to create the resources, https://cloud.oracle.com/identity/compartments"
  type        = string
  default     = ""
}
variable "oracle_tenancy_ocid" {
  description = "Oracle Cloud Tenancy OCID to create the resources, https://cloud.oracle.com/tenancy"
  type        = string
  default     = ""
}
variable "oracle_user_ocid" {
  description = "Oracle Cloud User OCID to create the resources, https://cloud.oracle.com/identity/domains/my-profile"
  type        = string
  default     = ""
}
variable "oracle_fingerprint" {
  description = "API key fingerprint for Oracle Cloud User to create the resources, https://cloud.oracle.com/identity/domains/my-profile/api-keys"
  type        = string
  default     = ""
}
variable "oracle_private_key_path" {
  description = "SSH private key path for for Oracle Cloud User to create the resources, https://cloud.oracle.com/identity/domains/my-profile/api-keys"
  type        = string
  default     = ""
}
variable "oracle_region" {
  description = "Oracle Cloud Region to create the resources"
  type        = string
  default     = ""
}

variable "ubuntu_version" {
  description = "Ubuntu version"
  type        = string
  default     = "22.04"
  validation {
    condition     = var.ubuntu_version == "22.04"
    error_message = "Please specify the correct ubuntu version, currently only 22.04 is supported"
  }
}
