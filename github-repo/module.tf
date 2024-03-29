resource "github_repository" "repository" {
  name               = var.repo_name
  description        = var.description
  auto_init          = var.auto_init
  visibility         = var.visibility
  topics             = var.topics
  archive_on_destroy = var.archive_on_destroy # probably want this in prod, but not for testing
}

resource "github_repository_file" "default-gitignore" {
  repository          = github_repository.repository.name
  branch              = "main"
  # This could be the metadata from the object like the above line. but it complained about decrepit
  file                = ".gitignore"
  content             = file("default-files/.gitignore")
  commit_message      = "[skip ci] Managed by Terraform"
  commit_author       = "Terraform User" # TODO remove all of these once we move to APP
  commit_email        = "terraform@example.com" # TODO remove all of these once we move to APP
  overwrite_on_create = false
}

resource "github_repository_file" "default-workflow-sonarqube" {
  repository          = github_repository.repository.name
  branch              = "main"
  file                = ".github/workflows/sonarqube.yaml"
  #https://docs.github.com/en/actions/managing-workflow-runs/skipping-workflow-runs
  content             = file("default-files/sonarqube.yaml")
  commit_message      = "[skip ci] Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = false
}

resource "github_repository_file" "default-sonarqube-config" {
  repository          = github_repository.repository.name
  branch              = "main"
  file                = "sonar-project.properties"
  content             = templatefile("default-files/sonar-project.properties.tftpl", {
    project = github_repository.repository.name
  })
  commit_message      = "[skip ci] Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = false
}

resource "github_repository_collaborator" "extra_members" {
  for_each   = {for member in var.extra_members : "${github_repository.repository.name}-${member.name}" => member}
  repository = github_repository.repository.name
  username   = each.value.name
  permission = each.value.permission
  depends_on = [github_repository.repository]
}
  
