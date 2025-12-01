data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

locals {
  my_ip = chomp(data.http.my_ip.response_body)
}


module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "docker-demo"

  instance_type               = "t3.small"
  monitoring                  = false
  subnet_id                   = module.vpc.public_subnets[0]
  user_data                   = file("${path.module}/docker-init.sh")
  key_name                    = module.key_pair.key_pair_name
  associate_public_ip_address = true
  iam_instance_profile        = module.iam_role.instance_profile_name
  security_group_ingress_rules = {
    allow_all_from_my_ip = {
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_ipv4   = "${local.my_ip}/32"
      description = "Allow all traffic from my current IP"
    }
  }

  tags = var.tags
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name           = "ec2-ssh"
  create_private_key = true
}

module "iam_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role"

  name = "ec2-ssm-role"

  trust_policy_permissions = {
    TrustRoleAndServiceToAssume = {
      actions = [
        "sts:AssumeRole",
        "sts:TagSession",
      ]
      principals = [{
        type        = "Service"
        identifiers = ["ec2.amazonaws.com"]
      }]
    }
  }
  policies = {
    SSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  create_instance_profile = true
}

output "private-key" {
  value     = module.key_pair.private_key_pem
  sensitive = true
}
