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

variable "vault_instance_metadata" {
  type    = map(string)
  default = {}

  description = "Additional metadata to add to the Vault instances."
}

variable "ip_address" {
  type        = string
  description = "The IP address to assign the forwarding rules to."
}

variable "vault_storage_bucket" {
  type        = string
  description = "Storage bucket name where the backend is configured. This bucket will not be created in this module"
}

variable "vault_service_account_email" {
  type        = string
  description = "Vault service account email"
}

variable "service_account_project_iam_roles" {
  type = list(string)

  default = [
    "roles/editor"
  ]

  description = "List of IAM roles for the Vault admin service account to function. If you need to add additional roles, update `service_account_project_additional_iam_roles` instead."
}

variable "service_account_storage_bucket_iam_roles" {
  type = list(string)

  default = [
    "roles/storage.objectAdmin",
  ]

  description = "List of IAM roles for the Vault admin service account to have on the storage bucket."
}

variable "vault_tls_bucket" {
  type    = string
  default = ""

  description = "GCS Bucket override where Vault will expect TLS certificates are stored."
}

variable "args" {
  type    = string
  default = ""

  description = "Additional command line arguments passed to  server"
}

variable "instance_labels" {
  type    = map(string)
  default = {}

  description = "Labels to apply to the instances."
}


variable "instance_metadata" {
  type    = map(string)
  default = {}

  description = "Additional metadata to add to the instances."
}

variable "instance_base_image" {
  type    = string
  default = "centos-7-v20180129"

  description = "Base operating system image in which to install . This must be a Debian-based system at the moment due to how the metadata startup script runs."
}

variable "service_account_name" {
  type    = string
  default = ""

  description = "Name of the Vault service account."

}

variable "request_path" {
  type    = string
  default = "/v1/sys/health?uninitcode=200"

  description = "Request path to check health status"
}

variable "instance_tags" {
  type    = list(string)
  default = []

  description = "Additional tags to apply to the instances. Note 'allow-ssh' and 'allow-' will be present on all instances."
}


variable "min_ready_sec" {
  description = "Minimum number of seconds to wait before considering a new or restarted instance as updated. This value must be from range. [0,3600]"
  type        = number
  default     = 0
}

variable "hc_initial_delay_secs" {
  description = "The number of seconds that the managed instance group waits before it applies autohealing policies to new instances or recently recreated instances."
  type        = number
  default     = 60
}

variable "zones" {
  description = "The zones to distribute instances across.  If empty, all zones in the region are used.  ['us-west1-a', 'us-west1-b', 'us-west1-c']"
  type        = list(string)
  default     = []
}

variable "domain_name" {
  description = "custom domain names."
  type        = string
  default     = ""
}


variable "kms_protection_level" {
  type    = string
  default = "software"

  description = "The protection level to use for the KMS crypto key."
}


variable "load_balancing_scheme" {
  type    = string
  default = "EXTERNAL"

  description = "Options are INTERNAL or EXTERNAL. If `EXTERNAL`, the forwarding rule will be of type EXTERNAL and a public IP will be created. If `INTERNAL` the type will be INTERNAL and a random RFC 1918 private IP will be assigned"
}

variable "vault_log_level" {
  type    = string
  default = "warn"

  description = "Log level to run Vault in. See the Vault documentation for valid values."
}

variable "min_num_servers" {
  type    = string
  default = "1"

  description = "Minimum number of Vault server nodes in the autoscaling group. The group will not have less than this number of nodes."
}

variable "vault_machine_type" {
  type    = string
  default = "n1-standard-4"

  description = "Machine type to use for Vault instances."
}

variable "max_num_servers" {
  type    = string
  default = "5"

  description = "Maximum number of Vault server nodes to run at one time. The group will not autoscale beyond this number."
}

variable "vault_port" {
  type    = string
  default = "8200"

  description = "Numeric port on which to run and expose Vault."
}

variable "lb_port" {
  type    = string
  default = ""

  description = "Numeric port on which to run and expose Vault."
}

variable "vault_proxy_port" {
  type    = string
  default = "8201"

  description = "Port to expose Vault's health status endpoint on over HTTP on /. This is required for the health checks to verify Vault's status is using an external load balancer. Only the health status endpoint is exposed, and it is only accessible from Google's load balancer addresses."
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

variable "vault_ui_enabled" {
  type    = string
  default = true

  description = "Controls whether the Vault UI is enabled and accessible."
}

variable "vault_version" {
  type    = string
  default = ""

  description = "Version of vault to install. This version must be 1.0+ and must be published on the HashiCorp releases service."

}

variable "http_proxy" {
  type    = string
  default = ""

  description = "HTTP proxy for downloading agents and vault executable on startup. Only necessary if allow_public_egress is false. This is only used on the first startup of the Vault cluster and will NOT set the global HTTP_PROXY environment variable. i.e. If you configure Vault to manage credentials for other services, default HTTP routes will be taken."
}

variable "user_startup_script" {
  type    = string
  default = ""

  description = "Additional user-provided code injected after Vault is setup"
}

variable "vault_update_policy_type" {
  type        = string
  default     = "OPPORTUNISTIC"
  description = "Options are OPPORTUNISTIC or PROACTIVE. If `PROACTIVE`, the instance group manager proactively executes actions in order to bring instances to their target versions"
}

variable "project_services" {
  type = list(string)

  default = [
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]

  description = "List of services to enable on the project where Vault will run. These services are required in order for this Vault setup to function."
}
