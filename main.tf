locals {
  github_repos      = yamldecode(file("repos.yaml"))
  github_teams      = yamldecode(file("teams.yaml"))
  repo_team_binding = distinct(flatten([
  for each_repo in local.github_repos : [
  for team in each_repo.teams : {
    team_id         = team.name
    repo            = each_repo.name
    team_permission = team.permission
  }
  ]
  ]))
}

module "repo" {
  for_each           = {for repo in local.github_repos : repo.name => repo} # Sets the index if i understand
  source             = "./github-repo"
  repo_name          = each.value.name
  visibility         = each.value.visibility
  extra_members      = each.value.extra-members
  archive_on_destroy = true
}
resource "sonarqube_project" "main" {
  for_each = module.repo
  name       = each.value.repo_instance
  project    = each.value.repo_instance
  visibility = "public"
}
# We do need to set the AIM setting
# We also need to rename the branch name
# This can either be done with extending the library or http
# TODO Suggestions. Put default branch somewhere as an input so we can set the sonarqube branch. Alternatively see if you can do some kind of https thing for that
# And here is the most stupid suggestion that might work. Set the organization default branch to something other then main during the run, then at the end set it back
# https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository
# Above is a data-source that seem to know what the default branch is
# https://developer.hashicorp.com/terraform/language/data-sources
resource "github_team" "teams" {
  for_each    = {for team in local.github_teams : team.name => team} # Sets the index if i understand
  name        = each.value.name
  description = each.value.description
  privacy     = each.value.privacy
}
# Add this https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_members
# Figure out how to do it as a for_each, looks nested
#https://medium.com/@larry_nguyen/how-to-repeat-resources-block-in-terraform-using-loops-and-variables-36b13726d638
resource "github_team_repository" "team-bind" {
  for_each   = {for team in local.repo_team_binding : "${team.repo}-${team.team_id}" => team}
  team_id    = each.value.team_id
  repository = each.value.repo
  permission = each.value.team_permission
  depends_on = [resource.github_team.teams]
}
resource "github_branch" "development" {
  repository    = module.repo["devops-test2"].repo_instance
  branch        = "development"
  source_branch = "main"
  depends_on    = [module.repo]
}


resource "github_actions_organization_secret" "SONAR_TOKEN" {
  secret_name     = "SONAR_TOKEN"
  visibility      = "private"
  encrypted_value = base64encode(var.sonar_token)
}


resource "github_actions_organization_secret" "SONAR_URL" {
  secret_name     = "SONAR_URL"
  visibility      = "private"
  encrypted_value = base64encode(var.sonar_url)
}
