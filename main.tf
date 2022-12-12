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
  member_team_binding = distinct(flatten([
  for each_team in local.github_teams : [
  for member in each_team.members : {
    username = member
    team_id  = each_team.name
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
data "github_repository" "repo_data" {
  for_each   = module.repo
  full_name = each.value.repo_instance.full_name
}
resource "sonarqube_project" "project" {
  for_each   = module.repo
  name       = each.value.repo_instance.name
  project    = each.value.repo_instance.name
  visibility = "public"
}
# TODO we could reference maybe something like ${each.value.repo_instance.default_branch}. i know its decrecated but we arent using it to set, but to retrieve? Or data source?
# I dunno yet if the data source also works as depends on or if i have to be explicit here
data "http" "set_branch" {
  for_each = module.repo
  url    = "${var.sonar_url}/api/project_branches/rename?name=${data.github_repository.repo_data[each.value.repo_instance.full_name].default_branch}&project=${each.value.repo_instance.name}" //TODO felix fatta hur vi passar branch
  method = "POST"
  request_headers = {
    Authorization = "Basic ${base64encode(format("%s:",var.sonar_admin_token))}"
  }
  lifecycle {
    postcondition {
      condition     = contains([204], self.status_code)
      error_message = "Status code invalid"
    }
  }
  depends_on = [sonarqube_project.project]
}
data "http" "set_alm" {
  for_each = module.repo
  url    = "${var.sonar_url}/api/alm_settings/set_github_binding?almSetting=GitHub&monorepo=no&project=${each.value.repo_instance.name}&repository=${each.value.repo_instance.full_name}" //TODO felix fatta hur vi passar branch
  method = "POST"
  request_headers = {
    Authorization = "Basic ${base64encode(format("%s:",var.sonar_admin_token))}"
  }
  lifecycle {
    postcondition {
      condition     = contains([204], self.status_code)
      error_message = "Status code invalid"
    }
  }
  depends_on = [sonarqube_project.project]
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
resource "github_team_membership" "some_team_membership" {
  for_each = {for team-membership in local.member_team_binding : "${team-membership.team_id}-${team-membership.username}" => team-membership}
  team_id  = github_team.teams[each.value.team_id].id
  username = each.value.username
  role     = "member"
  depends_on = [resource.github_team.teams]
}
resource "github_team_repository" "team-bind" { # TODO Should this be moved to the github module? Its part of the repository in a way right ? Just make sure teams are created before repos when strap
  for_each   = {for team in local.repo_team_binding : "${team.repo}-${team.team_id}" => team}
  team_id    = each.value.team_id
  repository = each.value.repo
  permission = each.value.team_permission
  depends_on = [resource.github_team.teams,module.repo]
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
