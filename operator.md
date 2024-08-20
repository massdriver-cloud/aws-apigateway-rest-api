## AWS API Gateway REST API

Amazon API Gateway is a fully managed service for creating, deploying, and managing APIs at any scale. It enables you to create RESTful APIs to access AWS or other web services, as well as data stored in the AWS Cloud.

### Design Decisions

1. **Endpoint Configuration**: The API Gateway can be configured to use either `REGIONAL` or `EDGE` endpoints, depending on your use case and performance requirements. This module supports both configurations.
2. **Domain and DNS**: If DNS is enabled, a fully qualified domain (FQDN) and associated SSL/TLS certificates will be managed. Separate certificates and hosted zones are managed for regional and edge configurations.
3. **Alarms and Monitoring**: The module includes automated alarms for client errors (4XX), server errors (5XX), and latency thresholds. These alarms are configured with AWS CloudWatch and alert via SNS topics.
4. **Security**: Integrated with IAM for role-based access and sets up necessary assume roles for secure API deployment.

### Runbook

#### Unable to Access API Gateway Endpoint

If users are experiencing issues accessing the API Gateway endpoint.

Check the API Gateway deployment status:

```sh
aws apigateway get-rest-api --rest-api-id <your_rest_api_id> --region <your_region>
```
This command retrieves the details of the specified RestAPI. Verify that the `endpointConfiguration` matches your deployment and that there are no error messages.

#### SSL Certificate Issues

If there are SSL/TLS certificate issues, especially when DNS is enabled.

Check the ACM certificate status:

```sh
aws acm describe-certificate --certificate-arn <your_certificate_arn> --region <your_region>
```

Ensure the certificate status is `ISSUED`. If it is in a different state, there may be issues with the validation process.

#### API Gateway Latency Problems

If the API Gateway appears to have high latency.

Query the CloudWatch metrics for latency:

```sh
aws cloudwatch get-metric-statistics --namespace AWS/ApiGateway --metric-name Latency --dimensions Name=ApiName,Value=<your_api_name> --start-time <start_time> --end-time <end_time> --period 300 --statistics Average --region <your_region>
```

This gives you the average latency over a specified period. 

#### High Rate of 4XX Errors

When there are a lot of client error responses from the API endpoints.

Fetch the CloudWatch metrics for 4XX errors:

```sh
aws cloudwatch get-metric-statistics --namespace AWS/ApiGateway --metric-name 4XXError --dimensions Name=ApiName,Value=<your_api_name> --start-time <start_time> --end-time <end_time> --period 300 --statistics Sum --region <your_region>
```

This retrieves the sum of 4XXError metrics, which is useful to debug client-side issues.

#### High Rate of 5XX Errors

When server errors are high within your API.

Fetch the CloudWatch metrics for 5XX errors:

```sh
aws cloudwatch get-metric-statistics --namespace AWS/ApiGateway --metric-name 5XXError --dimensions Name=ApiName,Value=<your_api_name> --start-time <start_time> --end-time <end_time> --period 300 --statistics Sum --region <your_region>
```

This retrieves the sum of 5XXError metrics, useful for debugging server-side issues.

