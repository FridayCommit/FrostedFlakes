terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    sonarqube = {
      source  = "jdamata/sonarqube"
      version = "0.15.3"
    }
  }
}

provider "github" {
  owner = var.gh_org
  token = var.gh_token
}
#provider "github" {
#  app_auth {
#    id              = var.app_id              # or `GITHUB_APP_ID`
#    installation_id = var.app_installation_id # or `GITHUB_APP_INSTALLATION_ID`
#    pem_file        = var.app_pem_file        # or `GITHUB_APP_PEM_FILE`
#  }
#}
provider "sonarqube" {
  token = var.sonar_admin_token
  host  = var.sonar_url
}