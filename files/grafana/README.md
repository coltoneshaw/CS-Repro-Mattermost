# Grafana Configuration

This directory contains the configuration for Grafana, which serves as the visualization and dashboarding platform for the CS Repro environment.

## Overview

Grafana is an open-source platform for monitoring and observability that allows you to query, visualize, alert on, and understand your metrics, logs, and traces.

## Current Setup

- Running as a single instance (version 10.0.4)
- Available at http://localhost:3000
- Default credentials: admin/admin

## Directory Structure

- **dashboards/**: Contains JSON dashboard definitions
  - `enhanced_logs.json`: Dashboard for viewing and filtering Mattermost logs
  - `kpiMetrics.json`: Dashboard for key performance indicators
  - `metricsv2.json`: Dashboard for detailed application metrics
  - `bonusMetrics.json`: Dashboard for additional metrics

- **provisioning/**: Contains automatic provisioning configurations
  - `datasources/`: Configures data source connections
  - `dashboards/`: Sets up dashboard loading

## Data Sources

The environment is configured with the following data sources:

1. **Prometheus** (Default): For metrics collection
   - URL: http://prometheus:9090
   - Used by most of the metric dashboards

2. **Loki**: For log aggregation
   - URL: http://loki:3100
   - Used by the enhanced_logs dashboard
   - Queries using the LogQL language

## Log Dashboard

The `enhanced_logs.json` dashboard is designed to work with logs collected via Alloy and stored in Loki. It provides:

- Log filtering by level (error, warn, info, debug)
- Visual metrics about log levels and counts
- Error tracking and analysis
- Time-series views of log patterns

The dashboard queries use the label `job="mattermost"` to filter logs from the Mattermost application.

## Best Practices

When modifying dashboards:
- Export/backup existing dashboards before making major changes
- Test queries in the Explore interface before adding to dashboards
- Use variables for consistent filtering across panels
- Maintain consistent styling

## More Information

- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
- [Dashboard JSON Model](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/dashboard-json-model/)
- [LogQL in Grafana](https://grafana.com/docs/grafana/latest/datasources/loki/query-editor/)