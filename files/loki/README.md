# Loki Configuration

This directory contains the configuration for Grafana Loki, which serves as the log storage and aggregation system in this environment.

## Overview

Loki is a horizontally-scalable, highly-available, multi-tenant log aggregation system designed by Grafana Labs. It is optimized for efficiently storing and querying logs from Kubernetes and microservices deployments.

## Current Setup

- Running as a single instance in this CS Repro environment
- Available at http://localhost:3100
- Receives logs from Grafana Alloy (which replaced Promtail)

## Configuration Details

The `loki-config.yaml` file contains the core configuration for the Loki service:

- **Storage**: Configured to use the local filesystem for simplicity
- **Schema**: Uses the v11 schema with appropriate index/chunk configurations
- **Compaction**: Enabled to optimize storage over time
- **Limits**: Configured with reasonable defaults for this environment
- **Frontend**: Configured for basic query handling

## Querying Logs

Logs can be queried in several ways:

1. **LogQL via Grafana**: The primary and most user-friendly method
2. **Direct Loki API**: Using the API endpoints at http://localhost:3100/loki/api/v1/
3. **LogCLI**: If installed, you can use Grafana's logcli tool

Example LogQL queries:
```
{job="mattermost"} | json | level=~"error|warn"
{job="mattermost"} | json | level="error" | line_format "{{.msg}}"
```

## Labels

The current configuration uses the following key labels:

- `job`: The source application ("mattermost")
- `level`: The log level (error, warn, info, debug, etc.)
- `service_name`: Identifies the service
- `filename`: The source log file

## More Information

- [Grafana Loki Documentation](https://grafana.com/docs/loki/latest/)
- [LogQL Query Language](https://grafana.com/docs/loki/latest/logql/)