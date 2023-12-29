data "aws_route53_zone" "public" {
  name = var.hosted-zone-name
  private_zone = false
}
