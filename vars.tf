variable "tags" {
  type = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}
