terraform {
  backend "remote" {
    organization = "DevOps-saddique-terraform"

    workspaces {
      name = "saddique-dev"
    }
  }
}