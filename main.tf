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
  github_repos = yamldecode(file("repos.yaml"))
  github_teams = yamldecode(file("teams.yaml"))
  repo_team_binding = distinct(flatten([
    for each_repo in local.github_repos : [
      for team in each_repo.teams : {
        team_id = team.name
        repo    = each_repo.name
        team_permission = team.permission
      }
  ]]))
}

module "repo" {
  for_each           = { for repo in local.github_repos : repo.name => repo } # Sets the index if i understand
  source             = "./github-repo"
  repo_name          = each.value.name
  visibility         = each.value.visibility
  extra_members = each.value.extra-members
  archive_on_destroy = false
}

resource "github_team" "teams" {
  for_each    = { for team in local.github_teams : team.name => team } # Sets the index if i understand
  name        = each.value.name
  description = each.value.description
  privacy     = each.value.privacy
}
resource "github_team_repository" "team-bind" {
  for_each   = { for team in local.repo_team_binding : "${team.repo}-${team.team_id}" => team }
  team_id    = each.value.team_id
  repository = each.value.repo
  permission = each.value.team_permission
  depends_on = [resource.github_team.teams]
}
resource "github_branch" "development" {
  repository    = module.repo["Repo2"].repo_instance
  branch        = "development"
  source_branch = "main"
  depends_on    = [module.repo]
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
