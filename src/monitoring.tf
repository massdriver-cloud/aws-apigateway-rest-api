locals {
  automated_alarms = {
    # 4XXError SUM > (TotalRequests * (Threshold / 100))
    client_errors = {
      threshold = 1
      period    = 300
    }

    # 5XXError SUM > (TotalRequests * (Threshold / 100))
    server_errors = {
      threshold = 0.1
      period    = 300
    }

    # Latency AVG > Threshold
    latency = {
      threshold = 1000
      period    = 300
    }
  }

  alarms_map = {
    "AUTOMATED" = local.automated_alarms
    "DISABLED"  = {}
    "CUSTOM"    = lookup(var.monitoring, "alarms", local.automated_alarms)
  }

  alarms = lookup(local.alarms_map, var.monitoring.mode, local.automated_alarms)
}

module "alarm_channel" {
  source      = "github.com/massdriver-cloud/terraform-modules//aws-alarm-channel?ref=8997456"
  md_metadata = var.md_metadata
}

module "client_errors_alarm" {
  count               = lookup(local.alarms, "client_errors", null) == null ? 0 : 1
  source              = "github.com/massdriver-cloud/terraform-modules//aws/cloudwatch-alarm-expression?ref=29df3b2"
  sns_topic_arn       = module.alarm_channel.arn
  md_metadata         = var.md_metadata
  alarm_name          = "${var.md_metadata.name_prefix}-4XXError"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  message             = "API Gateway ${var.md_metadata.name_prefix}: Sum 4XXErrors > % ${(local.alarms.client_errors.threshold / 100)}"
  display_name        = "API Gateway 4XX Errors"
  threshold           = local.alarms.client_errors.threshold
  display_metric_key  = "m2"

  metric_queries = {
    m1 = {
      metric = {
        metric_name = "Count"
        namespace   = "AWS/ApiGateway"
        period      = local.alarms.client_errors.period
        stat        = "Sum"
        dimensions = {
          ApiName = var.md_metadata.name_prefix
        }
      }
    }

    m2 = {
      metric = {
        metric_name = "4XXError"
        namespace   = "AWS/ApiGateway"
        period      = local.alarms.client_errors.period
        stat        = "Sum"
        dimensions = {
          ApiName = var.md_metadata.name_prefix
        }
      }
    }

    m3 = {
      expression  = "m2 / m1"
      label       = "Client Errors"
      return_data = true
    }
  }
}

module "server_errors_alarm" {
  count               = lookup(local.alarms, "server_errors", null) == null ? 0 : 1
  source              = "github.com/massdriver-cloud/terraform-modules//aws/cloudwatch-alarm-expression?ref=29df3b2"
  sns_topic_arn       = module.alarm_channel.arn
  md_metadata         = var.md_metadata
  alarm_name          = "${var.md_metadata.name_prefix}-5XXError"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  message             = "API Gateway ${var.md_metadata.name_prefix}: Sum 5XXErrors > % ${(local.alarms.client_errors.threshold / 100)}"
  display_name        = "API Gateway 5XX Errors"
  threshold           = local.alarms.server_errors.threshold
  display_metric_key  = "m2"

  metric_queries = {
    m1 = {
      metric = {
        metric_name = "Count"
        namespace   = "AWS/ApiGateway"
        period      = local.alarms.server_errors.period
        stat        = "Sum"
        dimensions = {
          ApiName = var.md_metadata.name_prefix
        }
      }
    }

    m2 = {
      metric = {
        metric_name = "5XXError"
        namespace   = "AWS/ApiGateway"
        period      = local.alarms.server_errors.period
        stat        = "Sum"
        dimensions = {
          ApiName = var.md_metadata.name_prefix
        }
      }
    }

    m3 = {
      expression  = "m2 / m1"
      label       = "Server Errors"
      return_data = true
    }
  }
}

module "latency" {
  count               = lookup(local.alarms, "latency", null) == null ? 0 : 1
  source              = "github.com/massdriver-cloud/terraform-modules//aws/cloudwatch-alarm?ref=378f3a3"
  sns_topic_arn       = module.alarm_channel.arn
  md_metadata         = var.md_metadata
  alarm_name          = "${var.md_metadata.name_prefix}-Latency"
  display_name        = "Average Latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  message             = "API Gateway ${var.md_metadata.name_prefix}: Avg Latency > ${(local.alarms.latency.threshold)} seconds"
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = local.alarms.latency.period
  statistic           = "Average"
  threshold           = local.alarms.latency.threshold
  dimensions = {
    ApiName = var.md_metadata.name_prefix
  }
}
