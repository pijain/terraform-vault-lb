variable "project_id" {
  type = string

  description = "ID of the project in which to create resources and add IAM bindings."
}

variable "host_project_id" {
  type    = string
  default = ""

  description = "ID of the host project if using Shared VPC"
}

variable "region" {
  type    = string
  default = "us-east1"

  description = "Region in which to create resources."
}

variable "subnet" {
  type        = string
  description = "The self link of the VPC subnetwork for . By default, one will be created for you."
}

variable "network" {
  type        = string
  description = "By default, one will be created for you."
}

variable "instance_name" {
  type        = string
  description = "Instance name"
}

variable "ip_address" {
  type        = string
  description = "The IP address to assign the forwarding rules to."
}

variable "vault_storage_bucket" {
  type        = string
  description = "Storage bucket name where the backend is configured. This bucket will not be created in this module"
}

variable "instance_base_image" {
  type    = string
  //default = "projects/digital-messaging-lab/global/images/vts26"
  default = ""

  description = "Base operating system image in which to install . This must be a Debian-based system at the moment due to how the metadata startup script runs."
}

variable "service_account_name" {
  type    = string
  default = ""

  description = "Name of the Vault service account."

}

variable "instance_tags" {
  type    = list(string)
  default = []

  description = "Additional tags to apply to the instances. Note 'allow-ssh' and 'allow-' will be present on all instances."
}

variable "zones" {
  description = "The zones to distribute instances across.  If empty, all zones in the region are used.  ['us-west1-a', 'us-west1-b', 'us-west1-c']"
  type        = list(string)
  default     = []
}

variable "domain_name" {
  description = "Custom domain names."
  type        = string
  default     = ""
}

variable "vault_machine_type" {
  type    = string
  default = ""

  description = "Machine type to use for Vault instances."
}

variable "vault_port" {
  type    = string
  default = ""

  description = "Numeric port on which to run and expose Vault."
}

variable "lb_port" {
  type    = string
  default = ""

  description = "Numeric port on which to run https loadbalancer."
}

variable "vault_tls_cert" {
  type    = string
  default = ""

  description = "GCS object path within the vault_tls_bucket. This is the vault server certificate."

}

variable "vault_tls_key" {
  type    = string
  default = ""

  description = "Encrypted and base64 encoded GCS object path within the vault_tls_bucket. This is the Vault TLS private key."
}

variable "vault_version" {
  type    = string
  default = ""

  description = "Version of vault to install. This version must be 1.0+ and must be published on the HashiCorp releases service."

}