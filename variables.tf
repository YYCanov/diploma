variable "public_key_path" {
  description = "Path to public key file"
  default = "~/diploma/keys/id_ed25.pub"
}

variable "token" {
  description = "Yandex Cloud security OAuth token"
  default = ""
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID where resources will be created"
  default = ""
}

variable "cloud_id" {
  description = "Yandex Cloud ID where resources will be created"
  default = ""
}

variable "service_account_id" {
  description = "Yandex Cloud service accpunt ID whom resources will be created"
  default = ""
}

variable "zone" {
  description = "Yandex Cloud default Zone for provisoned resources"
  default     = "ru-central1-a"
}

variable "zones" {
  description = "Yandex Cloud default Zone for provisoned resources"
  default     = ["ru-central1-a","ru-central1-b","ru-central1-c"]
}

variable "yc_image_family" {
  description = "family"
  # default     = "lemp"
  default     = "debian-11"
}

# variable "image_id" {
#   default = "fd8a67rb91j689dqp60h" # it's debian-11
# }

variable "cluster_size" {
  default = 2
}

variable "instance_cores" {
  description = "Cores per one instance"
  default     = "2"
}

variable "instance_memory" {
  description = "Memory in GB per one instance"
  default     = "1"
}

variable "instance_platform" {
  description = "ID of the hardware platform of the VM"
  default     = "standard-v1"
}

variable "tg_gr_name" {
  default = "target_gr_my"
}
