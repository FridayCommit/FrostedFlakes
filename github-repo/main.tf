resource "github_repository" "repository" {
  name = var.repo_name
  description = var.description
  auto_init   = var.auto_init
  visibility = var.visibility
  archive_on_destroy = var.archive_on_destroy # probably want this in prod, but not for testing
}

resource "github_repository_file" "default-gitignore" {
  repository     = github_repository.repository.name
  branch         = var.default_branch # This could be the metadata from the object like the above line. but it complained about decrepit
  file           = ".gitignore"
  content        = file("default-files/.gitignore")
  commit_message = "Managed by Terraform"
  commit_author  = "Terraform User"
  commit_email   = "terraform@example.com"
}

resource "github_repository_file" "default-workflow-sonarqube" {
  repository     = github_repository.repository.name
  branch         = var.default_branch
  file           = ".github/workflows/sonarqube.yaml"
  content        = file("default-files/sonarqube.yaml")
  commit_message = "Managed by Terraform"
  commit_author  = "Terraform User"
  commit_email   = "terraform@example.com"
}

resource "github_repository_file" "default-sonarqube-config" {
  repository     = github_repository.repository.name
  branch         = var.default_branch
  file           = "sonar-project.properties"
  content        = templatefile("default-files/sonar-project.properties.tftpl",{project=github_repository.repository.name})
  commit_message = "Managed by Terraform"
  commit_author  = "Terraform User"
  commit_email   = "terraform@example.com"
}