resource "massdriver_artifact" "api_gateway" {
  field                = "api_gateway"
  provider_resource_id = module.api_gateway.arn
  name                 = "Api Gateway: ${var.md_metadata.name_prefix}"
  artifact = jsonencode(
    {
      data = {
        infrastructure = {
          arn              = module.api_gateway.arn
          stage_arn        = module.api_gateway.stage_arn
          root_resource_id = module.api_gateway.root_resource_id
        }
      }
      specs = {
        aws = {
          region = var.rest_api.region
        }
      }
    }
  )
}
