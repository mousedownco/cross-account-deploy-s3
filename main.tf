provider aws {
  region = "us-east-2"
}
provider aws {
  alias  = "tools"
  region = var.tools_region
  assume_role {
    role_arn = "arn:aws:iam::${var.tools_account_number}:role/${var.tools_account_role}"
  }
}

provider aws {
  alias  = "prod"
  region = var.prod_region
  assume_role {
    role_arn = "arn:aws:iam::${var.prod_account_number}:role/${var.prod_account_role}"
  }
}
