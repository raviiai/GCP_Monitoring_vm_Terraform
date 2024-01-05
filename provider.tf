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
  credentials = file("C:/Users/myrem/Downloads/warm-bonfire-337209-19bf75d55b1b.json")
  project     = var.project_id
  region      = var.region
}

provider "random" {}