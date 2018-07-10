variable public_key_path {
  description = "Path to the public key used to connect to instance"
}

variable private_key_path {
  description = "Path to the public key used to connect to instance"
  default     = "~/.ssh/appuser"
}

variable zone {
  description = "Zone"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable app_provisioner_toggle {
  description = "Turn on/turn off provisioners"
  default     = "0"
}

variable db_address {
  description = "Turn on/turn off provisioners"
  default     = ""
}
