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

# Red5 Pro autoscaling Node group
variable "node_group_origins_min" {
  description = "Number of minimum Origins"
  type        = number
  default     = 1
}
variable "node_group_origins_max" {
  description = "Number of maximum Origins"
  type        = number
  default     = 20
}
variable "node_group_origins_instance_type" {
  description = "Instance type for Origins"
  type        = string
  default     = "VM.Standard.E4.Flex-1-4"
}
variable "node_group_origins_volume_size" {
  description = "Volume size in GB for Origins. Minimum 50GB"
  type        = number
  default     = 50
  validation {
    condition     = var.node_group_origins_volume_size >= 50
    error_message = "The node_group_origins_volume_size value must be a valid! Minimum 50"
  }
}
variable "node_group_edges_min" {
  description = "Number of minimum Edges"
  type        = number
  default     = 1
}
variable "node_group_edges_max" {
  description = "Number of maximum Edges"
  type        = number
  default     = 40
}
variable "node_group_edges_instance_type" {
  description = "Instance type for Edges"
  type        = string
  default     = "VM.Standard.E4.Flex-1-4"
}
variable "node_group_edges_volume_size" {
  description = "Volume size in GB for Edges. Minimum 50GB"
  type        = number
  default     = 50
  validation {
    condition     = var.node_group_edges_volume_size >= 50
    error_message = "The node_group_edges_volume_size value must be a valid! Minimum 50"
  }
}
variable "node_group_transcoders_min" {
  description = "Number of minimum Transcoders"
  type        = number
  default     = 1
}
variable "node_group_transcoders_max" {
  description = "Number of maximum Transcoders"
  type        = number
  default     = 20
}
variable "node_group_transcoders_instance_type" {
  description = "Instance type for Transcoders"
  type        = string
  default     = "VM.Standard.E4.Flex-1-4"
}
variable "node_group_transcoders_volume_size" {
  description = "Volume size in GB for Transcoders. Minimum 50GB"
  type        = number
  default     = 50
  validation {
    condition     = var.node_group_transcoders_volume_size >= 50
    error_message = "The node_group_transcoders_volume_size value must be a valid! Minimum 50"
  }
}
variable "node_group_relays_min" {
  description = "Number of minimum Relays"
  type        = number
  default     = 1
}
variable "node_group_relays_max" {
  description = "Number of maximum Relays"
  type        = number
  default     = 20
}
variable "node_group_relays_instance_type" {
  description = "Instance type for Relays"
  type        = string
  default     = "VM.Standard.E4.Flex-1-4"
}
variable "node_group_relays_volume_size" {
  description = "Volume size in GB for Relays. Minimum 50GB"
  type        = number
  default     = 50
  validation {
    condition     = var.node_group_relays_volume_size >= 50
    error_message = "The node_group_relays_volume_size value must be a valid! Minimum 50"
  }
}

variable "stream_manager_ip" {
  description = "Stream manager's ip"
  type        = string
}

variable "stream_manager_auth_user" {
  description = "value to set the user name for Stream Manager 2.0 authentication"
  type        = string
  default     = ""
}
variable "stream_manager_auth_password" {
  description = "value to set the user password for Stream Manager 2.0 authentication"
  type        = string
  default     = ""
}

variable "oracle_region" {
  description = "Oracle Cloud Region to create the resources"
  type        = string
  default     = ""
}

variable "subnet_name" {
  description = "VCN subnet name"
  type        = string
}

variable "red5pro_node_network_security_group" {
    type = string
}

variable "red5pro_node_image_name" {
    type = string
}

# Extra configuration for Red5 Pro autoscaling nodes
variable "node_config_webhooks" {
  description = "Webhooks configuration - (Optional) https://www.red5.net/docs/special/webhooks/overview/"
  type = object({
    enable           = bool
    target_nodes     = list(string)
    webhook_endpoint = string
  })
  default = {
    enable           = false
    target_nodes     = []
    webhook_endpoint = ""
  }
}
variable "node_config_social_pusher" {
  description = "Social Pusher configuration - (Optional) https://www.red5.net/docs/development/social-media-plugin/rest-api/"
  type = object({
    enable       = bool
    target_nodes = list(string)
  })
  default = {
    enable       = false
    target_nodes = []
  }
}

variable "node_config_round_trip_auth" {
  description = "Round trip authentication configuration - (Optional) https://www.red5.net/docs/special/authplugin/simple-auth/"
  type = object({
    enable                   = bool
    target_nodes             = list(string)
    auth_host                = string
    auth_port                = number
    auth_protocol            = string
    auth_endpoint_validate   = string
    auth_endpoint_invalidate = string
  })
  default = {
    enable                   = false
    target_nodes             = []
    auth_host                = ""
    auth_port                = 443
    auth_protocol            = "https://"
    auth_endpoint_validate   = "/validateCredentials"
    auth_endpoint_invalidate = "/invalidateCredentials"
  }
}

variable "node_config_restreamer" {
  description = "Restreamer configuration - (Optional) https://www.red5.net/docs/special/restreamer/overview/"
  type = object({
    enable               = bool
    target_nodes         = list(string)
    restreamer_tsingest  = bool
    restreamer_ipcam     = bool
    restreamer_whip      = bool
    restreamer_srtingest = bool
  })
  default = {
    enable               = false
    target_nodes         = []
    restreamer_tsingest  = false
    restreamer_ipcam     = false
    restreamer_whip      = false
    restreamer_srtingest = false
  }
}