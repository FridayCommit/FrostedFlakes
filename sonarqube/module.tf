resource "sonarqube_project" "project" {
  name       = var.repo_name
  project    = var.repo_name
  visibility = "public"
}

data "http" "set_branch" {
  url             = "${var.sonar_url}/api/project_branches/rename?name=${var.default_branch}&project=${var.repo_name}"
  method          = "POST"
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
  url             = "${var.sonar_url}/api/alm_settings/set_github_binding?almSetting=GitHub&monorepo=no&project=${var.repo_name}&repository=${var.full_repo_name}"
  method          = "POST"
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
