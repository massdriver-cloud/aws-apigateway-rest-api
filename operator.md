## AWS API Gateway

AWS API Gateway is a fully managed service that makes it easy for developers to create, publish, maintain, monitor, and secure APIs at any scale. It allows you to create RESTful APIs and WebSocket APIs that enable real-time two-way communication applications.

### Design Decisions

- **Regional vs. Edge-Optimized Configuration:** The configuration supports both regional and edge-optimized endpoints. The module automatically selects the appropriate ACM certificate based on the endpoint type.
- **Automated Monitoring and Alarms:** The module comes with predefined CloudWatch alarms for client errors, server errors, and latency. These alarms are configurable and can be disabled or customized.
- **DNS Integration:** The module can integrate with Route 53 DNS to provide a fully qualified domain name for the API Gateway, including optional validation via ACM.
- **AWS Provider Configuration:** The module supports cross-region deployments using multiple AWS provider configurations.

### Runbook

#### Diagnosing API Gateway 4XX Errors

4XX errors usually indicate issues with client-side requests. This script checks for recent 4XX errors logged in CloudWatch.

```sh
aws logs filter-log-events \
  --log-group-name '/aws/apigateway/${api_name}' \
  --filter-pattern '4XX' \
  --start-time $(date -d '1 hour ago' +%s)000 \
  --end-time $(date +%s)000
```

You should see logs returned that match 4XX errors.

#### Diagnosing API Gateway 5XX Errors

5XX errors typically indicate server-side issues. Use this script to check for recent 5XX errors in CloudWatch logs.

```sh
aws logs filter-log-events \
  --log-group-name '/aws/apigateway/${api_name}' \
  --filter-pattern '5XX' \
  --start-time $(date -d '1 hour ago' +%s)000 \
  --end-time $(date +%s)000
```

Logs containing 5XX errors will be displayed.

#### Checking Latency Metrics

Latency issues can degrade the user experience. Use the following command to check latency metrics.

```sh
aws cloudwatch get-metric-statistics --namespace AWS/ApiGateway \
  --metric-name Latency \
  --dimensions Name=ApiName,Value=${api_name} \
  --start-time $(date -u -d '1 hours ago' +%FT%TZ) \
  --end-time $(date -u +%FT%TZ) \
  --period 60 --statistics Average
```

Expect to see data points reflecting average latency.

#### Validating DNS Configuration

To verify that the DNS settings are correct, you can query your API's domain.

```sh
nslookup ${fq_domain}
```

The command should return the correct CNAME or A record pointing to the API Gateway.

#### AWS CLI: Get API Gateway Details

To fetch details about your API Gateway, use:

```sh
aws apigateway get-rest-apis
```

Check the JSON response to ensure that the API endpoint and related configurations are as expected.

#### CloudFormation Stack Health

If your stack was deployed via CloudFormation, check its status:

```sh
aws cloudformation describe-stacks --stack-name ${stack_name}
```

Inspect the stack events and resources to diagnose any issues.



