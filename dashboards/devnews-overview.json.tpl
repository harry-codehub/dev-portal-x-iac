{
  "lenses": {
    "0": {
      "order": 0,
      "parts": {
        "0": {
          "position": { "x": 0, "y": 0, "colSpan": 12, "rowSpan": 1 },
          "metadata": {
            "inputs": [],
            "type": "Extension/HubsExtension/PartType/MarkdownPart",
            "settings": {
              "content": {
                "settings": {
                  "content": "## DevNews — ${environment} — Service Health\nRequests · failures · latency · Functions · Cosmos · pipeline health. The dashboard time range applies to all metric tiles; log tiles use the window in their query.",
                  "title": "",
                  "subtitle": ""
                }
              }
            }
          }
        },
        "1": {
          "position": { "x": 0, "y": 1, "colSpan": 6, "rowSpan": 4 },
          "metadata": {
            "inputs": [
              {
                "name": "options",
                "value": {
                  "chart": {
                    "metrics": [
                      {
                        "resourceMetadata": { "id": "${app_insights_id}" },
                        "name": "requests/count",
                        "aggregationType": 7,
                        "namespace": "microsoft.insights/components",
                        "metricVisualization": { "displayName": "Server requests" }
                      }
                    ],
                    "title": "Requests",
                    "titleKind": 1,
                    "visualization": {
                      "chartType": 2,
                      "legendVisualization": { "isVisible": true, "position": 2, "hideSubtitle": false },
                      "axisVisualization": { "x": { "isVisible": true, "axisType": 2 }, "y": { "isVisible": true, "axisType": 1 } }
                    }
                  }
                }
              },
              { "name": "sharedTimeRange", "isOptional": true }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {}
          }
        },
        "2": {
          "position": { "x": 6, "y": 1, "colSpan": 6, "rowSpan": 4 },
          "metadata": {
            "inputs": [
              {
                "name": "options",
                "value": {
                  "chart": {
                    "metrics": [
                      {
                        "resourceMetadata": { "id": "${app_insights_id}" },
                        "name": "requests/failed",
                        "aggregationType": 7,
                        "namespace": "microsoft.insights/components",
                        "metricVisualization": { "displayName": "Failed requests" }
                      }
                    ],
                    "title": "Failed requests",
                    "titleKind": 1,
                    "visualization": {
                      "chartType": 2,
                      "legendVisualization": { "isVisible": true, "position": 2, "hideSubtitle": false },
                      "axisVisualization": { "x": { "isVisible": true, "axisType": 2 }, "y": { "isVisible": true, "axisType": 1 } }
                    }
                  }
                }
              },
              { "name": "sharedTimeRange", "isOptional": true }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {}
          }
        },
        "3": {
          "position": { "x": 0, "y": 5, "colSpan": 6, "rowSpan": 4 },
          "metadata": {
            "inputs": [
              {
                "name": "options",
                "value": {
                  "chart": {
                    "metrics": [
                      {
                        "resourceMetadata": { "id": "${app_insights_id}" },
                        "name": "requests/duration",
                        "aggregationType": 4,
                        "namespace": "microsoft.insights/components",
                        "metricVisualization": { "displayName": "Server response time" }
                      }
                    ],
                    "title": "Server response time (avg)",
                    "titleKind": 1,
                    "visualization": {
                      "chartType": 2,
                      "legendVisualization": { "isVisible": true, "position": 2, "hideSubtitle": false },
                      "axisVisualization": { "x": { "isVisible": true, "axisType": 2 }, "y": { "isVisible": true, "axisType": 1 } }
                    }
                  }
                }
              },
              { "name": "sharedTimeRange", "isOptional": true }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {}
          }
        },
        "4": {
          "position": { "x": 6, "y": 5, "colSpan": 6, "rowSpan": 4 },
          "metadata": {
            "inputs": [
              {
                "name": "options",
                "value": {
                  "chart": {
                    "metrics": [
                      {
                        "resourceMetadata": { "id": "${app_insights_id}" },
                        "name": "exceptions/server",
                        "aggregationType": 7,
                        "namespace": "microsoft.insights/components",
                        "metricVisualization": { "displayName": "Server exceptions" }
                      }
                    ],
                    "title": "Server exceptions",
                    "titleKind": 1,
                    "visualization": {
                      "chartType": 2,
                      "legendVisualization": { "isVisible": true, "position": 2, "hideSubtitle": false },
                      "axisVisualization": { "x": { "isVisible": true, "axisType": 2 }, "y": { "isVisible": true, "axisType": 1 } }
                    }
                  }
                }
              },
              { "name": "sharedTimeRange", "isOptional": true }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {}
          }
        },
        "5": {
          "position": { "x": 0, "y": 9, "colSpan": 6, "rowSpan": 4 },
          "metadata": {
            "inputs": [
              {
                "name": "options",
                "value": {
                  "chart": {
                    "metrics": [
                      {
                        "resourceMetadata": { "id": "${function_app_id}" },
                        "name": "OnDemandFunctionExecutionCount",
                        "aggregationType": 1,
                        "namespace": "microsoft.web/sites",
                        "metricVisualization": { "displayName": "On-demand executions" }
                      },
                      {
                        "resourceMetadata": { "id": "${function_app_id}" },
                        "name": "AlwaysReadyFunctionExecutionCount",
                        "aggregationType": 1,
                        "namespace": "microsoft.web/sites",
                        "metricVisualization": { "displayName": "Always-ready executions" }
                      }
                    ],
                    "title": "Function execution count",
                    "titleKind": 1,
                    "visualization": {
                      "chartType": 2,
                      "legendVisualization": { "isVisible": true, "position": 2, "hideSubtitle": false },
                      "axisVisualization": { "x": { "isVisible": true, "axisType": 2 }, "y": { "isVisible": true, "axisType": 1 } }
                    }
                  }
                }
              },
              { "name": "sharedTimeRange", "isOptional": true }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {}
          }
        },
        "6": {
          "position": { "x": 6, "y": 9, "colSpan": 6, "rowSpan": 4 },
          "metadata": {
            "inputs": [
              {
                "name": "options",
                "value": {
                  "chart": {
                    "metrics": [
                      {
                        "resourceMetadata": { "id": "${function_app_id}" },
                        "name": "OnDemandFunctionExecutionUnits",
                        "aggregationType": 1,
                        "namespace": "microsoft.web/sites",
                        "metricVisualization": { "displayName": "On-demand units" }
                      },
                      {
                        "resourceMetadata": { "id": "${function_app_id}" },
                        "name": "AlwaysReadyFunctionExecutionUnits",
                        "aggregationType": 1,
                        "namespace": "microsoft.web/sites",
                        "metricVisualization": { "displayName": "Always-ready units" }
                      }
                    ],
                    "title": "Function execution units (GB-s proxy)",
                    "titleKind": 1,
                    "visualization": {
                      "chartType": 2,
                      "legendVisualization": { "isVisible": true, "position": 2, "hideSubtitle": false },
                      "axisVisualization": { "x": { "isVisible": true, "axisType": 2 }, "y": { "isVisible": true, "axisType": 1 } }
                    }
                  }
                }
              },
              { "name": "sharedTimeRange", "isOptional": true }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {}
          }
        },
        "7": {
          "position": { "x": 0, "y": 13, "colSpan": 6, "rowSpan": 4 },
          "metadata": {
            "inputs": [
              {
                "name": "options",
                "value": {
                  "chart": {
                    "metrics": [
                      {
                        "resourceMetadata": { "id": "${cosmos_account_id}" },
                        "name": "TotalRequests",
                        "aggregationType": 7,
                        "namespace": "microsoft.documentdb/databaseaccounts",
                        "metricVisualization": { "displayName": "Total requests" }
                      }
                    ],
                    "title": "Cosmos DB — total requests",
                    "titleKind": 1,
                    "visualization": {
                      "chartType": 2,
                      "legendVisualization": { "isVisible": true, "position": 2, "hideSubtitle": false },
                      "axisVisualization": { "x": { "isVisible": true, "axisType": 2 }, "y": { "isVisible": true, "axisType": 1 } }
                    }
                  }
                }
              },
              { "name": "sharedTimeRange", "isOptional": true }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {}
          }
        },
        "8": {
          "position": { "x": 6, "y": 13, "colSpan": 6, "rowSpan": 4 },
          "metadata": {
            "inputs": [
              {
                "name": "options",
                "value": {
                  "chart": {
                    "metrics": [
                      {
                        "resourceMetadata": { "id": "${cosmos_account_id}" },
                        "name": "TotalRequestUnits",
                        "aggregationType": 1,
                        "namespace": "microsoft.documentdb/databaseaccounts",
                        "metricVisualization": { "displayName": "Total request units (RU)" }
                      }
                    ],
                    "title": "Cosmos DB — request units (RU)",
                    "titleKind": 1,
                    "visualization": {
                      "chartType": 2,
                      "legendVisualization": { "isVisible": true, "position": 2, "hideSubtitle": false },
                      "axisVisualization": { "x": { "isVisible": true, "axisType": 2 }, "y": { "isVisible": true, "axisType": 1 } }
                    }
                  }
                }
              },
              { "name": "sharedTimeRange", "isOptional": true }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {}
          }
        },
        "9": {
          "position": { "x": 0, "y": 17, "colSpan": 6, "rowSpan": 4 },
          "metadata": {
            "inputs": [
              {
                "name": "options",
                "value": {
                  "chart": {
                    "metrics": [
                      {
                        "resourceMetadata": { "id": "${cosmos_account_id}" },
                        "name": "ServerSideLatency",
                        "aggregationType": 4,
                        "namespace": "microsoft.documentdb/databaseaccounts",
                        "metricVisualization": { "displayName": "Server-side latency" }
                      }
                    ],
                    "title": "Cosmos DB — server-side latency (avg)",
                    "titleKind": 1,
                    "visualization": {
                      "chartType": 2,
                      "legendVisualization": { "isVisible": true, "position": 2, "hideSubtitle": false },
                      "axisVisualization": { "x": { "isVisible": true, "axisType": 2 }, "y": { "isVisible": true, "axisType": 1 } }
                    }
                  }
                }
              },
              { "name": "sharedTimeRange", "isOptional": true }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {}
          }
        },
        "10": {
          "position": { "x": 6, "y": 17, "colSpan": 6, "rowSpan": 4 },
          "metadata": {
            "inputs": [
              {
                "name": "options",
                "value": {
                  "chart": {
                    "metrics": [
                      {
                        "resourceMetadata": { "id": "${storage_account_id}" },
                        "name": "Transactions",
                        "aggregationType": 1,
                        "namespace": "microsoft.storage/storageaccounts",
                        "metricVisualization": { "displayName": "Transactions" }
                      }
                    ],
                    "title": "Storage — transactions",
                    "titleKind": 1,
                    "visualization": {
                      "chartType": 2,
                      "legendVisualization": { "isVisible": true, "position": 2, "hideSubtitle": false },
                      "axisVisualization": { "x": { "isVisible": true, "axisType": 2 }, "y": { "isVisible": true, "axisType": 1 } }
                    }
                  }
                }
              },
              { "name": "sharedTimeRange", "isOptional": true }
            ],
            "type": "Extension/HubsExtension/PartType/MonitorChartPart",
            "settings": {}
          }
        },
        "11": {
          "position": { "x": 0, "y": 21, "colSpan": 12, "rowSpan": 5 },
          "metadata": {
            "inputs": [
              { "name": "resourceTypeMode", "isOptional": true },
              { "name": "ComponentId", "isOptional": true },
              { "name": "Scope", "value": { "resourceIds": [ "${app_insights_id}" ] }, "isOptional": true },
              { "name": "PartId", "value": "a1b2c3d4-0011-4a11-9a11-000000000011", "isOptional": true },
              { "name": "Version", "value": "2.0", "isOptional": true },
              { "name": "TimeRange", "value": "P1D", "isOptional": true },
              { "name": "DashboardId", "isOptional": true },
              { "name": "DraftRequestParameters", "isOptional": true },
              { "name": "Query", "value": "requests\n| where timestamp > ago(24h)\n| summarize Requests = count(), Failures = countif(success == false), P50ms = round(percentile(duration, 50), 0), P95ms = round(percentile(duration, 95), 0) by name\n| order by Requests desc", "isOptional": true },
              { "name": "ControlType", "value": "AnalyticsGrid", "isOptional": true },
              { "name": "SpecificChart", "isOptional": true },
              { "name": "PartTitle", "value": "Top operations — volume, failures, latency (24h)", "isOptional": true },
              { "name": "PartSubTitle", "value": "${environment}", "isOptional": true },
              { "name": "Dimensions", "isOptional": true },
              { "name": "LegendOptions", "isOptional": true },
              { "name": "IsQueryContainTimeRange", "value": false, "isOptional": true }
            ],
            "type": "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart",
            "settings": {}
          }
        },
        "12": {
          "position": { "x": 0, "y": 26, "colSpan": 12, "rowSpan": 5 },
          "metadata": {
            "inputs": [
              { "name": "resourceTypeMode", "isOptional": true },
              { "name": "ComponentId", "isOptional": true },
              { "name": "Scope", "value": { "resourceIds": [ "${app_insights_id}" ] }, "isOptional": true },
              { "name": "PartId", "value": "a1b2c3d4-0012-4a12-9a12-000000000012", "isOptional": true },
              { "name": "Version", "value": "2.0", "isOptional": true },
              { "name": "TimeRange", "value": "P1D", "isOptional": true },
              { "name": "DashboardId", "isOptional": true },
              { "name": "DraftRequestParameters", "isOptional": true },
              { "name": "Query", "value": "exceptions\n| where timestamp > ago(24h)\n| summarize Count = count(), Last = max(timestamp), Message = any(outerMessage) by type, operation_Name\n| order by Count desc", "isOptional": true },
              { "name": "ControlType", "value": "AnalyticsGrid", "isOptional": true },
              { "name": "SpecificChart", "isOptional": true },
              { "name": "PartTitle", "value": "Exceptions by type & operation (24h)", "isOptional": true },
              { "name": "PartSubTitle", "value": "${environment}", "isOptional": true },
              { "name": "Dimensions", "isOptional": true },
              { "name": "LegendOptions", "isOptional": true },
              { "name": "IsQueryContainTimeRange", "value": false, "isOptional": true }
            ],
            "type": "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart",
            "settings": {}
          }
        },
        "13": {
          "position": { "x": 0, "y": 31, "colSpan": 12, "rowSpan": 5 },
          "metadata": {
            "inputs": [
              { "name": "resourceTypeMode", "isOptional": true },
              { "name": "ComponentId", "isOptional": true },
              { "name": "Scope", "value": { "resourceIds": [ "${app_insights_id}" ] }, "isOptional": true },
              { "name": "PartId", "value": "a1b2c3d4-0013-4a13-9a13-000000000013", "isOptional": true },
              { "name": "Version", "value": "2.0", "isOptional": true },
              { "name": "TimeRange", "value": "P7D", "isOptional": true },
              { "name": "DashboardId", "isOptional": true },
              { "name": "DraftRequestParameters", "isOptional": true },
              { "name": "Query", "value": "requests\n| where timestamp > ago(7d)\n| where name has_any ('Pipeline', 'Crawl', 'Social', 'Video', 'Orchestrator', 'Curate', 'Discover', 'Dedupe', 'Persist', 'Render', 'Publish', 'Script', 'Select')\n| summarize Runs = count(), Failures = countif(success == false), LastRun = max(timestamp) by name\n| order by LastRun desc", "isOptional": true },
              { "name": "ControlType", "value": "AnalyticsGrid", "isOptional": true },
              { "name": "SpecificChart", "isOptional": true },
              { "name": "PartTitle", "value": "Durable pipeline health — runs & failures (7d)", "isOptional": true },
              { "name": "PartSubTitle", "value": "${environment} · crawl / social / video orchestrators & activities", "isOptional": true },
              { "name": "Dimensions", "isOptional": true },
              { "name": "LegendOptions", "isOptional": true },
              { "name": "IsQueryContainTimeRange", "value": false, "isOptional": true }
            ],
            "type": "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart",
            "settings": {}
          }
        },
        "14": {
          "position": { "x": 0, "y": 36, "colSpan": 12, "rowSpan": 4 },
          "metadata": {
            "inputs": [
              { "name": "resourceTypeMode", "isOptional": true },
              { "name": "ComponentId", "isOptional": true },
              { "name": "Scope", "value": { "resourceIds": [ "${app_insights_id}" ] }, "isOptional": true },
              { "name": "PartId", "value": "a1b2c3d4-0014-4a14-9a14-000000000014", "isOptional": true },
              { "name": "Version", "value": "2.0", "isOptional": true },
              { "name": "TimeRange", "value": "P1D", "isOptional": true },
              { "name": "DashboardId", "isOptional": true },
              { "name": "DraftRequestParameters", "isOptional": true },
              { "name": "Query", "value": "traces\n| where timestamp > ago(24h)\n| summarize ['Curated'] = countif(message startswith 'Activity: Curating article'), ['Curation failures'] = countif(message startswith 'Curation failed for'), ['Persisted'] = countif(message startswith 'Activity: Persisting news item'), ['Persist failures'] = countif(message startswith 'Persist failed for'), ['Bluesky posts'] = countif(message startswith 'Published text post to Bluesky'), ['LinkedIn posts'] = countif(message startswith 'Published text post to LinkedIn'), ['YouTube videos'] = countif(message startswith 'Published YouTube Short')", "isOptional": true },
              { "name": "ControlType", "value": "AnalyticsGrid", "isOptional": true },
              { "name": "SpecificChart", "isOptional": true },
              { "name": "PartTitle", "value": "Pipeline output — items produced (24h)", "isOptional": true },
              { "name": "PartSubTitle", "value": "${environment} · zero across the row = pipeline produced nothing", "isOptional": true },
              { "name": "Dimensions", "isOptional": true },
              { "name": "LegendOptions", "isOptional": true },
              { "name": "IsQueryContainTimeRange", "value": false, "isOptional": true }
            ],
            "type": "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart",
            "settings": {}
          }
        },
        "15": {
          "position": { "x": 0, "y": 40, "colSpan": 12, "rowSpan": 4 },
          "metadata": {
            "inputs": [
              { "name": "resourceTypeMode", "isOptional": true },
              { "name": "ComponentId", "isOptional": true },
              { "name": "Scope", "value": { "resourceIds": [ "${app_insights_id}" ] }, "isOptional": true },
              { "name": "PartId", "value": "a1b2c3d4-0015-4a15-9a15-000000000015", "isOptional": true },
              { "name": "Version", "value": "2.0", "isOptional": true },
              { "name": "TimeRange", "value": "P30D", "isOptional": true },
              { "name": "DashboardId", "isOptional": true },
              { "name": "DraftRequestParameters", "isOptional": true },
              { "name": "Query", "value": "traces\n| where timestamp > ago(30d)\n| summarize LastArticle = maxif(timestamp, message startswith 'Activity: Persisting news item'), LastBluesky = maxif(timestamp, message startswith 'Published text post to Bluesky'), LastLinkedIn = maxif(timestamp, message startswith 'Published text post to LinkedIn'), LastVideo = maxif(timestamp, message startswith 'Video render completed')\n| extend ['Hours since last article'] = datetime_diff('hour', now(), LastArticle), ['Hours since last Bluesky post'] = datetime_diff('hour', now(), LastBluesky)\n| project ['Hours since last article'], ['Hours since last Bluesky post'], LastArticle, LastBluesky, LastLinkedIn, LastVideo", "isOptional": true },
              { "name": "ControlType", "value": "AnalyticsGrid", "isOptional": true },
              { "name": "SpecificChart", "isOptional": true },
              { "name": "PartTitle", "value": "Pipeline freshness — time since last output (30d lookback)", "isOptional": true },
              { "name": "PartSubTitle", "value": "${environment} · rising 'hours since' = silent stall", "isOptional": true },
              { "name": "Dimensions", "isOptional": true },
              { "name": "LegendOptions", "isOptional": true },
              { "name": "IsQueryContainTimeRange", "value": false, "isOptional": true }
            ],
            "type": "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart",
            "settings": {}
          }
        },
        "16": {
          "position": { "x": 0, "y": 44, "colSpan": 12, "rowSpan": 5 },
          "metadata": {
            "inputs": [
              { "name": "resourceTypeMode", "isOptional": true },
              { "name": "ComponentId", "isOptional": true },
              { "name": "Scope", "value": { "resourceIds": [ "${app_insights_id}" ] }, "isOptional": true },
              { "name": "PartId", "value": "a1b2c3d4-0016-4a16-9a16-000000000016", "isOptional": true },
              { "name": "Version", "value": "2.0", "isOptional": true },
              { "name": "TimeRange", "value": "P1D", "isOptional": true },
              { "name": "DashboardId", "isOptional": true },
              { "name": "DraftRequestParameters", "isOptional": true },
              { "name": "Query", "value": "dependencies\n| where timestamp > ago(24h) and success == false\n| summarize Failures = count(), Last = max(timestamp), Result = any(resultCode) by target, name, type\n| order by Failures desc", "isOptional": true },
              { "name": "ControlType", "value": "AnalyticsGrid", "isOptional": true },
              { "name": "SpecificChart", "isOptional": true },
              { "name": "PartTitle", "value": "Failed external dependencies (24h)", "isOptional": true },
              { "name": "PartSubTitle", "value": "${environment} · outbound calls to Anthropic / Creatomate / YouTube / LinkedIn / Bluesky / Cosmos", "isOptional": true },
              { "name": "Dimensions", "isOptional": true },
              { "name": "LegendOptions", "isOptional": true },
              { "name": "IsQueryContainTimeRange", "value": false, "isOptional": true }
            ],
            "type": "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart",
            "settings": {}
          }
        }
      }
    }
  },
  "metadata": {
    "model": {
      "timeRange": {
        "value": { "relative": { "duration": 24, "timeUnit": 1 } },
        "type": "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
      },
      "filterLocale": { "value": "en-us" },
      "filters": {
        "value": {
          "MsPortalFx_TimeRange": {
            "model": {
              "format": "utc",
              "granularity": "auto",
              "relative": "24h"
            },
            "displayCache": { "name": "UTC Time", "value": "Past 24 hours" },
            "filteredPartIds": []
          }
        }
      }
    }
  }
}
