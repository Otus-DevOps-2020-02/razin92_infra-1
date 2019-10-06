variable zone {
  description = "Instance zone"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable db_disk_image {
  description = "Disk image for reddit app's db'"
  default     = "reddit-db-base"
}
