locals {
  github_repos = yamldecode(file("repos.yaml"))
  github_teams = yamldecode(file("teams.yaml"))
  repo_team_binding = distinct(flatten([
    for each_repo in local.github_repos : [
      for team in each_repo.teams : {
        team_id         = team.name
        repo            = each_repo.name
        team_permission = team.permission
      }
    ]
  ]))
  member_team_binding = distinct(flatten([
    for each_team in local.github_teams : [
      for member in each_team.members : {
        username = member
        team_id  = each_team.name
      }
    ]
  ]))
}
resource "github_team" "teams" {
  for_each    = { for team in local.github_teams : team.name => team } # Sets the index if i understand
  name        = each.value.name
  description = each.value.description
  privacy     = each.value.privacy
}
# Add this https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_members
# Figure out how to do it as a for_each, looks nested
#https://medium.com/@larry_nguyen/how-to-repeat-resources-block-in-terraform-using-loops-and-variables-36b13726d638
resource "github_team_membership" "team_membership" {
  for_each   = { for team-membership in local.member_team_binding : "${team-membership.team_id}-${team-membership.username}" => team-membership }
  team_id    = github_team.teams[each.value.team_id].id
  username   = each.value.username
  role       = "member"
  depends_on = [github_team.teams]
}

# TODO: There should probably be one GitHub module, one SonarQube module, and so on. Then github-repository should be a submodule to that, so that we can handle org level settings. 
module "repo" {
  for_each           = { for repo in local.github_repos : repo.name => repo } # Sets the index if i understand
  source             = "./github-repo"
  repo_name          = each.value.name
  visibility         = each.value.visibility
  extra_members      = each.value.extra-members
  topics             = each.value.topics
  archive_on_destroy = true
  depends_on         = [github_team.teams]
}
data "github_repository" "repo_data" {
  for_each  = module.repo
  full_name = each.value.repo_instance.full_name
}
resource "github_team_repository" "team_bind" {
  # TODO Should this be moved to the github module? Its part of the repository in a way right ? Just make sure teams are created before repos when strap
  for_each   = { for team in local.repo_team_binding : "${team.repo}-${team.team_id}" => team }
  team_id    = each.value.team_id
  repository = each.value.repo
  permission = each.value.team_permission
  depends_on = [resource.github_team.teams, module.repo]
}

module "sonarqube" {
  # for_each       = { for repo in module.repo : repo => repo if repo.sonarqube_enabled }
  for_each       = data.github_repository.repo_data
  source         = "./sonarqube"
  repo_name      = each.value.name
  full_repo_name = each.value.full_name
  default_branch = each.value.default_branch
}

resource "github_actions_organization_secret" "SONAR_TOKEN" {
  secret_name     = "SONAR_TOKEN"
  visibility      = "private"
  plaintext_value = var.sonar_token # TODO fix
}


resource "github_actions_organization_secret" "SONAR_URL" {
  secret_name     = "SONAR_URL"
  visibility      = "private"
  plaintext_value = var.sonar_url
}
