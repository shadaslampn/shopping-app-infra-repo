data "aws_ami" "latest" {
  most_recent      = true
  owners           = ["self"]

  filter {
    name   = "name"
    values = ["${var.project_name}-${var.project_env}-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "tag:Project"
    values = ["${var.project_name}"]
  }
  
  filter {
    name   = "tag:Env"
    values = ["${var.project_env}"]
  }
}
