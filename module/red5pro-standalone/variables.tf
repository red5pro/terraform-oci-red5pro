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

# HTTPS/SSL variables for standalone/cluster/autoscale
variable "https_ssl_certificate" {
  description = "Enable SSL (HTTPS) on the Standalone Red5 Pro server"
  type        = string
  default     = "none"
  validation {
    condition     = var.https_ssl_certificate == "none" || var.https_ssl_certificate == "letsencrypt" || var.https_ssl_certificate == "imported"
    error_message = "The https_ssl_certificate value must be a valid! Example: none, letsencrypt, imported"
  }
}
variable "https_ssl_certificate_domain_name" {
  description = "Domain name for SSL certificate (letsencrypt/imported)"
  type        = string
  default     = ""
}
variable "https_ssl_certificate_email" {
  description = "Email for SSL certificate (letsencrypt)"
  type        = string
  default     = ""
}
variable "https_ssl_certificate_cert_path" {
  description = "Path to SSL certificate (imported)"
  type        = string
  default     = ""
}
variable "https_ssl_certificate_key_path" {
  description = "Path to SSL key (imported)"
  type        = string
  default     = ""
}

# Red5 Pro Standalone server configuration
variable "standalone_red5pro_instance_type" {
  description = "Red5 Pro Standalone server instance type"
  type        = string
  default     = "VM.Standard.E4.Flex"
}
variable "standalone_red5pro_instance_ocpu" {
  description = "Red5 Pro Standalone server instance cpu count(1 OCPU = 2vCPU)"
  type        = number
  default     = 1
}
variable "standalone_red5pro_instance_memory" {
  description = "Red5 Pro Standalone server instance memory"
  type        = number
  default     = 4
}
variable "standalone_red5pro_instance_volume_size" {
  description = "Red5 Pro Standalone server instance volume size in GB"
  type        = number
  default     = 50
  validation {
    condition     = var.standalone_red5pro_instance_volume_size >= 50
    error_message = "The standalone_red5pro_instance_volume_size value must be a valid! Minimum 50"
  }
}
variable "standalone_red5pro_inspector_enable" {
  description = "Red5 Pro Standalone server Inspector enable/disable (https://www.red5.net/docs/troubleshooting/inspector/overview/)"
  type        = bool
  default     = false
}
variable "standalone_red5pro_restreamer_enable" {
  description = "Red5 Pro Standalone server Restreamer enable/disable (https://www.red5.net/docs/special/restreamer/overview/)"
  type        = bool
  default     = false
}
variable "standalone_red5pro_socialpusher_enable" {
  description = "Red5 Pro Standalone server SocialPusher enable/disable (https://www.red5.net/docs/special/social-media-plugin/rest-api/)"
  type        = bool
  default     = false
}
variable "standalone_red5pro_suppressor_enable" {
  description = "Red5 Pro Standalone server Suppressor enable"
  type        = bool
  default     = false
}
variable "standalone_red5pro_hls_enable" {
  description = "Red5 Pro Standalone server HLS enable/disable (https://www.red5.net/docs/protocols/hls-plugin/overview/)"
  type        = bool
  default     = false
}
variable "standalone_red5pro_round_trip_auth_enable" {
  description = "Round trip authentication on the red5pro server enable/disable - Auth server should be deployed separately (https://www.red5.net/docs/special/round-trip-auth/overview/)"
  type        = bool
  default     = false
}
variable "standalone_red5pro_round_trip_auth_host" {
  description = "Round trip authentication server host"
  type        = string
  default     = ""
}
variable "standalone_red5pro_round_trip_auth_port" {
  description = "Round trip authentication server port"
  type        = number
  default     = 3000
}
variable "standalone_red5pro_round_trip_auth_protocol" {
  description = "Round trip authentication server protocol"
  type        = string
  default     = "http"
}
variable "standalone_red5pro_round_trip_auth_endpoint_validate" {
  description = "Round trip authentication server endpoint for validate"
  type        = string
  default     = "/validateCredentials"
}
variable "standalone_red5pro_round_trip_auth_endpoint_invalidate" {
  description = "Round trip authentication server endpoint for invalidate"
  type        = string
  default     = "/invalidateCredentials"
}

# SSH key configuration
variable "ssh_key_use_existing" {
  description = "SSH key pair configuration, true = use existing, false = create new"
  type        = bool
  default     = false
}
variable "ssh_key_existing_private_key_path" {
  description = "SSH private key path existing"
  type        = string
  default     = ""
}
variable "ssh_key_existing_public_key_path" {
  description = "SSH public key path existing"
  type        = string
  default     = ""
}

# Oracle Cloud Prvider basic configuration settings
variable "oracle_compartment_id" {
  description = "Oracle Cloud Compartment OCID to create the resources, https://cloud.oracle.com/identity/compartments"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "VCN subnet id"
  type        = string
}

variable "red5pro_standalone_network_security_group_id" {
  type = string
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

variable "ubuntu_version" {
  description = "Ubuntu version"
  type        = string
  default     = "22.04"
  validation {
    condition     = var.ubuntu_version == "22.04"
    error_message = "Please specify the correct ubuntu version, currently only 22.04 is supported"
  }
}
