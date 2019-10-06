variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  # Значение по умолчанию
  default = "europe-west1"
}

variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}

variable disk_image {
  description = "Disk image"
}

variable zone {
  description = "Instance zone"
  default     = "europe-west1-b"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable counter {
  default = 1
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable db_disk_image {
  description = "Disk image for reddit app's db'"
  default     = "reddit-db-base"
}

variable machine_type {
  description = "Type of creating VM"
  default     = "f1-micro"
}
