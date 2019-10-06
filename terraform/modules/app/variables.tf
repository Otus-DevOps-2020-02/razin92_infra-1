variable zone {
  description = "Instance zone"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable machine_type {
  description = "Type of creating VM"
  default     = "g1-small"
}

variable network_name {
  description = "Network used for the App"
  default     = "default"
}
