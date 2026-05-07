# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference

# Replace project id to your project, region to your preferred choice, and zone as well.



#Chewbacca: The Force needs coordinates.
#You need this first in order to see if you can authenticate to GCP



terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.31.0"
    }
  }
}

provider "google" {
  project = "my-project-id"
  region  = "us-central1"
  zone    = "us-central1-c"
}



