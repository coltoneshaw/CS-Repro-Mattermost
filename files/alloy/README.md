# Alloy Log Agent Configuration

This directory contains the configuration for Grafana Alloy, which has replaced Promtail as the log agent in this environment.

## Key Differences

- Alloy uses a component-based configuration format with `.alloy` extension
- The web UI is available at http://localhost:9080
- Alloy can handle logs, metrics, and traces in one agent
- Configuration is more flexible with the River language

## Configuration Explanation

The `config.alloy` file follows the component-based model where:

1. `loki.source.file` components directly collect logs from Mattermost log files
2. `loki.process` component parses and labels the JSON logs
3. `loki.write` component sends the logs to Loki

## Current Setup

Our configuration:
- Monitors Mattermost logs directly from mounted volumes
- Labels all logs with `job="mattermost"` for Grafana dashboard compatibility
- Extracts log level, message, and other metadata from JSON logs
- Sends logs to Loki service

## Converting Promtail Config to Alloy

If you need to update the configuration, you can convert Promtail configs to Alloy format with:

```bash
# Example using the alloy CLI (if installed locally)
alloy convert --source-format=promtail --output=config.alloy promtail-config.yaml
```

## Important Syntax Notes

- The River language used by Alloy requires commas at the end of each key-value pair in objects
- Trailing commas in lists and objects are supported and recommended

## More Information

- [Grafana Alloy Documentation](https://grafana.com/docs/alloy/latest/)
- [Migrating from Promtail to Alloy](https://grafana.com/docs/loki/latest/send-data/alloy/migrate-from-promtail/)