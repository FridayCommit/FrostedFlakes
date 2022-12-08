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
  for_each = { for repo in local.github_repos : repo.name => repo } # Sets the index if i understand
  source             = "./github-repo"
  repo_name          = each.value.name
  visibility         = each.value.visibility
  archive_on_destroy = false
}
resource "github_team" "teams" {
  for_each = { for team in local.config_privileges : team.team_id => team } # This ~works like an conditional if-statement when the team list is empty
  name        = each.value.team_id
  description = "Some cool team"
  privacy     = "closed"
  depends_on = [module.repo]
}
resource "github_team_repository" "team-bind" {
  for_each = { for team in local.config_privileges : "${team.team_id}-${team.repo}" => team }
  team_id    = each.value.team_id
  repository = each.value.repo
  permission = "pull"
  depends_on = [resource.github_team.teams]
}
resource "github_branch" "development" {
  repository    = module.repo["Repo2"].repo_instance
  branch        = "development"
  source_branch = "main"
  depends_on = [module.repo]
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
