# AWS API Gateway

Amazon API Gateway is a managed service that allows you to create, publish, maintain, monitor, and secure APIs at any scale. It handles all the tasks involved in accepting and processing up to hundreds of thousands of concurrent API calls, including traffic management, authorization and access control, monitoring, and API version management.

## Design Decisions

1. **Endpoint Configuration**:
   - Supports both `REGIONAL` and `EDGE` endpoint types.
   - Automatic provisioning of the appropriate ACM certificates based on the endpoint type and DNS configuration.

2. **DNS Integration**:
   - Conditional logic to enable DNS and ACM certificate management.
   - Uses Route53 for DNS resolution if enabled.

3. **Monitoring and Alarms**:
   - Automated CloudWatch alarms for 4XX and 5XX errors, and latency.
   - Configurable thresholds for monitoring key performance metrics.
   - Integration with a pre-defined SNS topic for alarm notifications.

4. **Infrastructure Artifact**:
   - Stores important attributes like `arn`, `stage_arn`, and `root_resource_id` for easy reference.

5. **Region Configuration**:
   - Defines primary and secondary AWS providers for regional deployments.

## Runbook

### API Gateway Returns 4XX Errors

If you are experiencing a large number of 4XX errors, this typically indicates a client-side issue such as a bad request or unauthorized request.

Check API Gateway Metrics for 4XX Errors:

```sh
aws cloudwatch get-metric-statistics --namespace AWS/ApiGateway --metric-name 4XXError --start-time $(date -u -d '15 minutes ago' +%FT%T) --end-time $(date -u +%FT%T) --period 60 --statistics Sum --dimensions Name=ApiName,Value=<api_name>
```

This command fetches the 4XX errors for your API over the last 15 minutes. Look for the `Sum` value.

### API Gateway Returns 5XX Errors

5XX errors indicate server-side issues, possibly within your API backend integrations.

Check API Gateway Metrics for 5XX Errors:

```sh
aws cloudwatch get-metric-statistics --namespace AWS/ApiGateway --metric-name 5XXError --start-time $(date -u -d '15 minutes ago' +%FT%T) --end-time $(date -u +%FT%T) --period 60 --statistics Sum --dimensions Name=ApiName,Value=<api_name>
```

This command returns the 5XX errors for your API over the last 15 minutes. Look for the `Sum` value.

### High Latency Issues

Latency issues can stem from various sources, including backend performance or network issues.

Check API Gateway Latency Metrics:

```sh
aws cloudwatch get-metric-statistics --namespace AWS/ApiGateway --metric-name Latency --start-time $(date -u -d '15 minutes ago' +%FT%T) --end-time $(date -u +%FT%T) --period 60 --statistics Average --dimensions Name=ApiName,Value=<api_name>
```

This command fetches the average latency for your API over the last 15 minutes. Look for the `Average` value.

### DNS Resolution Issues

If your custom domain is not resolving correctly to your API Gateway, ensure the Route 53 hosted zone settings are correct.

Verify Route 53 DNS Records:

```sh
aws route53 list-resource-record-sets --hosted-zone-id <hosted_zone_id>
```

Check if the DNS records match the configurations provided for your API Gateway endpoint.

### SSL/TLS Certificate Issues

Sometimes SSL/TLS handshake failures can cause API access issues. Ensure certificates are properly set up.

List ACM Certificates:

```sh
aws acm list-certificates
```

Describe Certificate:

```sh
aws acm describe-certificate --certificate-arn <certificate_arn>
```

Make sure the certificate status is `ISSUED` and is correctly associated with your API Gateway.

### IAM Role Issues

Incorrect permissions can lead to API Gateway failing to access required resources.

Verify IAM Role Policies:

```sh
aws iam list-attached-role-policies --role-name <role_name>
```

Check the policies and ensure they provide the necessary permissions for API Gateway operations.

