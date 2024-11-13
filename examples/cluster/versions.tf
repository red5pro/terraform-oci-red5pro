terraform {
  required_version = ">= 1.7.5"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.16"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}