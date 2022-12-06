resource "github_repository" "tf-example" {
  name      = "tf-example"

  description = "My awesome codebase"
  auto_init   = "true"

  visibility         = "public"
  # archive_on_destroy = "true" # probably want this in prod, but not for testing 
}

resource "github_repository_file" "default-gitignore" {
  repository          = github_repository.tf-example.name
  branch              = "main"
  file                = ".gitignore"
  content             = "**/*.tfstate \n node_modules"
  commit_message      = "Managed by Terraform"
  commit_author       = "Terraform User"
  commit_email        = "terraform@example.com"
  overwrite_on_create = true
}
