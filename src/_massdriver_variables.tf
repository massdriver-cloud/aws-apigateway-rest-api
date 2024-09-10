// Auto-generated variable declarations from massdriver.yaml
variable "aws_authentication" {
  type = object({
    data = object({
      arn         = string
      external_id = optional(string)
    })
    specs = object({
      aws = optional(object({
        region = optional(string)
      }))
    })
  })
}
variable "dns" {
  type = object({
    enabled     = optional(bool)
    hosted_zone = optional(string)
    sub_domain  = optional(string)
  })
}
variable "md_metadata" {
  type = object({
    default_tags = object({
      managed-by  = string
      md-manifest = string
      md-package  = string
      md-project  = string
      md-target   = string
    })
    deployment = object({
      id = string
    })
    name_prefix = string
    observability = object({
      alarm_webhook_url = string
    })
    package = object({
      created_at             = string
      deployment_enqueued_at = string
      previous_status        = string
      updated_at             = string
    })
    target = object({
      contact_email = string
    })
  })
}
variable "monitoring" {
  type = object({
    mode = optional(string)
    alarms = optional(object({
      client_errors = optional(object({
        period    = number
        threshold = number
      }))
      latency = optional(object({
        period    = number
        threshold = number
      }))
      server_errors = optional(object({
        period    = number
        threshold = number
      }))
    }))
  })
  default = null
}
variable "rest_api" {
  type = object({
    endpoint_configuration = string
    region                 = string
    stage_name             = string
  })
}
