# TF_VAR_sonar_url
variable "sonar_url" {
  description = "SonarQube url"
  type        = string
}
# TF_VAR_sonar_token
variable "sonar_token" {
  description = "SonarQube token"
  type        = string
}
# TF_VAR_gh_token
variable "gh_token" {
  description = "GitHub token"
  type        = string
  sensitive   = true
}
# TF_VAR_gh_org
variable "gh_org" {
  description = "GitHub Organization"
  type        = string
}
# TF_VAR_sonar_admin_token
variable "sonar_admin_token" {
  description = "SonarQube Admin Token"
  type        = string
  sensitive   = true
}
