resource "github_repository" "tf-example" {
  name = "tf-example"

  description = "My awesome codebase"
  auto_init   = "true"

  visibility = "public"
  # archive_on_destroy = "true" # probably want this in prod, but not for testing 
}

resource "github_repository_file" "default-gitignore" {
  repository     = github_repository.tf-example.name
  branch         = "main"
  file           = ".gitignore"
  content        = file("default-files/.gitignore")
  commit_message = "Managed by Terraform"
  commit_author  = "Terraform User"
  commit_email   = "terraform@example.com"
}

resource "github_repository_file" "default-workflow-sonarqube" {
  repository     = github_repository.tf-example.name
  branch         = "main"
  file           = ".github/workflows/sonarqube.yaml"
  content        = file("default-files/sonarqube.yaml")
  commit_message = "Managed by Terraform"
  commit_author  = "Terraform User"
  commit_email   = "terraform@example.com"
}

resource "github_repository_file" "default-sonarqube-config" {
  repository     = github_repository.tf-example.name
  branch         = "main"
  file           = "sonar-project.properties"
  content        = file("default-files/sonar-project.properties")
  commit_message = "Managed by Terraform"
  commit_author  = "Terraform User"
  commit_email   = "terraform@example.com"
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