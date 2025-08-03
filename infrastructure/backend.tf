terraform {
  backend "s3" {
    bucket = "redshifts-state"
    key    = "redshift/redshift.tfstate"
    region = "us-east-1"
  }
}