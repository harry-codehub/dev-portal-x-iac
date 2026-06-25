# =============================================================================
# AZURE PORTAL DASHBOARD
# Per-environment service-health board: platform metric tiles (requests,
# failures, latency, Functions, Cosmos, Storage) plus KQL log tiles over the
# telemetry the app already emits (requests/exceptions + durable-pipeline runs).
# Created only when Application Insights exists, since every tile targets it or
# resources that report into it.
# =============================================================================

resource "azurerm_portal_dashboard" "main" {
  count = var.enable_application_insights ? 1 : 0

  name                = "dash-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  # "hidden-title" sets the display name shown in the Azure portal.
  tags = merge(local.common_tags, {
    "hidden-title" = "DevNews ${var.environment} - Service Health"
  })

  dashboard_properties = templatefile("${path.module}/dashboards/devnews-overview.json.tpl", {
    environment        = var.environment
    app_insights_id    = azurerm_application_insights.main[0].id
    function_app_id    = azurerm_function_app_flex_consumption.api.id
    cosmos_account_id  = azurerm_cosmosdb_account.main.id
    storage_account_id = azurerm_storage_account.function.id
  })
}
