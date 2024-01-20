terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.10.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }

  }
}

provider "google" {
  #credentials = file("C:/Users/myrem/Desktop/terraform/Git/warm-bonfire-337209-7c4e7f083fdd.json")
  project = var.project_id
  region  = var.region
}

provider "random" {}


############## Comment Added