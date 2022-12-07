module "repo1" {
  source             = "./github-repo"
  repo_name          = "repo1"
  visibility         = "public"
  archive_on_destroy = false
}
module "repo2" {
  source             = "./github-repo"
  repo_name          = "repo2"
  visibility         = "public"
  archive_on_destroy = false
}


# Override default branch workaround
resource "github_branch" "development" {
  repository    = module.repo2.repo_instance
  branch        = "development"
  source_branch = "main"
}

resource "github_branch_default" "default" {
  repository = module.repo2.repo_instance
  branch     = github_branch.development.branch
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
