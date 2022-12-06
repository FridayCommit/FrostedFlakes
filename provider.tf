terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

variable "gh_token" {
  description = "GitHub token"
  type        = string
}

provider "github" {
  owner = "FridayCommit"
  token = var.gh_token
}