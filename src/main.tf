locals {
  fq_domain             = var.dns.enabled ? "${var.dns.sub_domain}.${data.aws_route53_zone.lookup[0].name}" : ""
  is_regional           = var.rest_api.endpoint_configuration == "REGIONAL"
  is_edge               = var.rest_api.endpoint_configuration == "EDGE"
  regional_or_edge_cert = var.dns.enabled ? (local.is_regional ? module.acm_regional_certificate[0].certificate_arn : module.acm_edge_certificate[0].certificate_arn) : ""
  hosted_zone_id        = var.dns.enabled ? split("/", var.dns.hosted_zone)[1] : ""
}

data "aws_route53_zone" "lookup" {
  count   = var.dns.enabled ? 1 : 0
  zone_id = local.hosted_zone_id
}

module "acm_edge_certificate" {
  count          = local.is_edge && var.dns.enabled ? 1 : 0
  source         = "github.com/massdriver-cloud/terraform-modules//aws/acm-certificate?ref=21b84cd"
  domain_name    = local.fq_domain
  hosted_zone_id = local.hosted_zone_id
  providers = {
    aws = aws.useast1
  }
}

module "acm_regional_certificate" {
  count          = local.is_regional && var.dns.enabled ? 1 : 0
  source         = "github.com/massdriver-cloud/terraform-modules//aws/acm-certificate?ref=21b84cd"
  domain_name    = local.fq_domain
  hosted_zone_id = local.hosted_zone_id
}

module "api_gateway" {
  source                 = "github.com/massdriver-cloud/terraform-modules//aws/api-gateway-rest-api?ref=f15c309"
  name                   = var.md_metadata.name_prefix
  endpoint_configuration = var.rest_api.endpoint_configuration
  domain                 = local.fq_domain
  hosted_zone_id         = local.hosted_zone_id
  certificate_arn        = local.regional_or_edge_cert
  stage_name             = var.rest_api.stage_name
  dns_enabled            = var.dns.enabled

  depends_on = [module.acm_edge_certificate, module.acm_regional_certificate]
}
