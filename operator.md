## AWS API Gateway REST API

Amazon API Gateway is a fully managed service that makes it easy for developers to create, publish, maintain, monitor, and secure APIs at any scale. With API Gateway, you can create RESTful APIs to enable applications to communicate with backend services such as AWS Lambda, EC2, or any HTTP-based APIs.

### Design Decisions

- **Endpoint Configuration**: Options are "REGIONAL" or "EDGE". This module supports both configurations and will automatically provision the necessary certificates (ACM) depending on the endpoint configuration.
- **DNS Support**: The module supports attaching a custom domain to the API Gateway using Amazon Route 53.
- **Monitoring Alarms**: Automated CloudWatch alarms for client errors (4XX), server errors (5XX), and latency are provided. These alerts can be customized or disabled based on user preferences.

### Runbook

#### Checking API Gateway Stage Deployment

To verify the deployment status of an API Gateway stage:

```sh
aws apigateway get-stage --rest-api-id <rest-api-id> --stage-name <stage-name>
```

This command fetches information about the specified stage, including deployment and configuration details.

#### Diagnosing 4XX Errors

To diagnose client-side errors (4XX):

1. **Fetch Recent Logs**

    ```sh
    aws logs filter-log-events --log-group-name <log-group-name> --filter-pattern "4XX"
    ```

2. **Analyze CloudWatch Metrics**

    ```sh
    aws cloudwatch get-metric-data --metric-name "4XXError" --namespace "AWS/ApiGateway" --dimensions Name=ApiName,Value=<api-name>
    ```

This helps to see the count and distribution of client-side errors in your API Gateway.

#### Diagnosing 5XX Errors

To diagnose server-side errors (5XX):

1. **Fetch Recent Logs**

    ```sh
    aws logs filter-log-events --log-group-name <log-group-name> --filter-pattern "5XX"
    ```

2. **Analyze CloudWatch Metrics**

    ```sh
    aws cloudwatch get-metric-data --metric-name "5XXError" --namespace "AWS/ApiGateway" --dimensions Name=ApiName,Value=<api-name>
    ```

3. **Check Lambda Errors (if applicable)**

    If your API Gateway integrates with AWS Lambda, check Lambda logs for errors:

    ```sh
    aws logs filter-log-events --log-group-name /aws/lambda/<lambda-function-name>
    ```

#### Latency Issues

To troubleshoot latency issues:

1. **Analyze CloudWatch Latency Metrics**

    ```sh
    aws cloudwatch get-metric-data --metric-name "Latency" --namespace "AWS/ApiGateway" --dimensions Name=ApiName,Value=<api-name>
    ```

2. **Check Backend Integration**

    Verify if the issue is with the backend service (e.g., AWS Lambda, EC2):

    - **Lambda**

      ```sh
      aws logs filter-log-events --log-group-name /aws/lambda/<lambda-function-name>
      ```

    - **EC2**

      SSH into the instance and check the application logs:

      ```sh
      ssh ec2-user@<public-ip>
      sudo tail -f /var/log/<application-log>.log
      ```

#### Custom Domain Configuration

To verify the status and details of a custom domain name:

```sh
aws apigateway get-domain-name --domain-name <custom-domain-name>
```

This command provides information about the custom domain name configuration, including its regional or edge endpoint type.

