variable "repo_name" {
  type = string
}
variable "full_repo_name" {
  type = string
}
variable "default_branch" {
  type    = string
  default = "main"
}
variable "sonar_url" {
  type    = string
}
variable "sonar_admin_token" {
  type    = string
}
