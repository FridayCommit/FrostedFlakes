#locals {
#  github_repos = yamldecode(file("repos.yaml"))
#  flattened_repositories = flatten([
#  for repo in local.github_repos : [
#  for n in repo.topics : {
#      topic    = n
#  }
#  ]
#  ])
#}
locals {
  github_repos= yamldecode(file("repos.yaml"))
  config_privileges = distinct(flatten([
  for each_repo in local.github_repos : [
  for team in each_repo.teams : {
    team_id = team
    repo = each_repo.name
  }
  ]]))
}
output "repos" {
  value = yamldecode(file("repos.yaml"))
}
output "repos2" {
  value = local.config_privileges
}
module "repo" {
  for_each = { for repo in local.github_repos : repo.name => repo }
  source             = "./github-repo"
  repo_name          = each.value.name
  visibility         = each.value.visibility
  archive_on_destroy = false
}
resource "github_branch" "development" {
  repository    = module.repo["Repo2"].repo_instance
  branch        = "development"
  source_branch = "main"
}
# TF_VAR_sonar_token
variable "sonar_token" {
  description = "SonarQube token"
  type        = string
}
resource "github_actions_organization_secret" "SONAR_TOKEN" {
  secret_name     = "SONAR_TOKEN"
  visibility      = "private"
  encrypted_value = var.sonar_token
}

# TF_VAR_sonar_url
variable "sonar_url" {
  description = "SonarQube url"
  type        = string
}
resource "github_actions_organization_secret" "SONAR_URL" {
  secret_name     = "SONAR_URL"
  visibility      = "private"
  encrypted_value = var.sonar_url
}
