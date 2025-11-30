variable "username" {
  type      = string
  sensitive = true
}

variable "password" {
  type      = string
  sensitive = true
}

variable "accelerator" {
  type = string
}

variable "base_packages" {
  type = list(string)
}

variable "debian_cloud_image_url" {
  type = string
}

variable "debian_cloud_image_checksum" {
  type = string
}

variable "image_name" {
  type = string
}

variable "output_directory" {
  type = string
}
