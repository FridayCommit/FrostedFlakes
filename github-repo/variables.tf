variable "repo_name" {
  type = string
}
variable "description" {
  type    = string
  default = ""
}
variable "auto_init" {
  type    = bool
  default = true
}
variable "visibility" {
  type    = string
  default = "internal"
}
variable "archive_on_destroy" {
  type    = bool
  default = true
}
variable "extra_members" {
  type = list(object({
    name       = string
    permission = string
  }))
  default = []
}
