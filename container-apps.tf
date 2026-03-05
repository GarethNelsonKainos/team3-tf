# ══════════════════════════════════════════════════════════════════════════════
# COMMENTED OUT — Uncomment after manually adding secrets to Key Vault:
#  - database-url
#  - jwt-secret
#  - postgres-password
#  - aws-access-key-id
#  - aws-secret-access-key

# Also uncomment the data sources in keyvault.tf before uncommenting these.
# ══════════════════════════════════════════════════════════════════════════════

# ── Postgres Container App ─────────────────────────────────────────────────────
# Internal TCP transport — accessible by backend via "postgres:5432"

resource "azurerm_container_app" "postgres" {
  name                         = "postgres"
  container_app_environment_id = azurerm_container_app_environment.container_app_environment.id
  resource_group_name          = module.resource_group.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.managed_identity.id]
  }

  registry {
    server   = var.acr_login_server
    identity = azurerm_user_assigned_identity.managed_identity.id
  }

  template {
    min_replicas = 1
    max_replicas = 1

    container {
      name   = "postgres"
      image  = "${var.acr_login_server}/postgres:16-alpine"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "postgres-user"
        value = var.postgres_user
      }

      env {
        name        = "postgres-password"
        secret_name = "postgres-password"
      }

      env {
        name  = "postgres-db"
        value = var.postgres_db
      }
    }
  }

  secret {
    name                = "postgres-password"
    key_vault_secret_id = data.azurerm_key_vault_secret.postgres_password.versionless_id
    identity            = azurerm_user_assigned_identity.managed_identity.id
  }

  ingress {
    external_enabled = false
    target_port      = 5432
    transport        = "tcp"
    exposed_port     = 5432

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = {
    environment = var.dev_environment
    managed_by  = "terraform"
  }

  depends_on = [
    azurerm_role_assignment.acr_pull,
    azurerm_role_assignment.kv_secrets_user,
  ]
}

# ── Backend Container App ──────────────────────────────────────────────────────
# Internal only — not reachable from the public internet.
# Frontend reaches it via its internal FQDN within the environment.

resource "azurerm_container_app" "backend" {
  name                         = "ca-backend-${var.dev_environment}"
  container_app_environment_id = azurerm_container_app_environment.container_app_environment.id
  resource_group_name          = module.resource_group.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.managed_identity.id]
  }

  registry {
    server   = var.acr_login_server
    identity = azurerm_user_assigned_identity.managed_identity.id
  }

  template {
    min_replicas = 1
    max_replicas = 3

    container {
      name   = "backend"
      image  = "${var.acr_login_server}/team3-backend:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name        = "database-url"
        secret_name = "database-url"
      }

      env {
        name  = "schema-name"
        value = var.schema_name
      }

      env {
        name        = "jwt-secret"
        secret_name = "jwt-secret"
      }

      env {
        name  = "cors_origin"
        value = var.cors_origin != "" ? var.cors_origin : "https://ca-frontend-${var.dev_environment}.${azurerm_container_app_environment.container_app_environment.default_domain}"
      }

      env {
        name  = "port"
        value = tostring(var.backend_port)
      }

      env {
        name  = "aws_region"
        value = var.aws_region
      }

      env {
        name        = "aws-access-key-id"
        secret_name = "aws-access-key-id"
      }

      env {
        name        = "aws-secret-access-key"
        secret_name = "aws-secret-access-key"
      }

      env {
        name  = "s3-bucket-name"
        secret_name = "s3-bucket-name"
      }
    }
  }

  secret {
    name                = "database-url"
    key_vault_secret_id = data.azurerm_key_vault_secret.database_url.versionless_id
    identity            = azurerm_user_assigned_identity.managed_identity.id
  }

  secret {
    name                = "jwt-secret"
    key_vault_secret_id = data.azurerm_key_vault_secret.jwt_secret.versionless_id
    identity            = azurerm_user_assigned_identity.managed_identity.id
  }

  secret {
    name                = "aws-access-key-id"
    key_vault_secret_id = data.azurerm_key_vault_secret.aws_access_key_id.versionless_id
    identity            = azurerm_user_assigned_identity.managed_identity.id
  }

  secret {
    name                = "aws-secret-access-key"
    key_vault_secret_id = data.azurerm_key_vault_secret.aws_secret_access_key.versionless_id
    identity            = azurerm_user_assigned_identity.managed_identity.id
  }

  ingress {
    external_enabled = false
    target_port      = var.backend_port
    transport        = "auto"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = {
    environment = var.dev_environment
    managed_by  = "terraform"
  }

  depends_on = [
    azurerm_role_assignment.acr_pull,
    azurerm_role_assignment.kv_secrets_user,
    azurerm_container_app.postgres,
  ]
}

# ── Frontend Container App ─────────────────────────────────────────────────────
# Publicly accessible. Reaches the backend via its internal FQDN.

resource "azurerm_container_app" "frontend" {
  name                         = "ca-frontend-${var.dev_environment}"
  container_app_environment_id = azurerm_container_app_environment.container_app_environment.id
  resource_group_name          = module.resource_group.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.managed_identity.id]
  }

  registry {
    server   = var.acr_login_server
    identity = azurerm_user_assigned_identity.managed_identity.id
  }

  template {
    min_replicas = 1
    max_replicas = 3

    container {
      name   = "frontend"
      image  = "${var.acr_login_server}/team3-frontend:latest"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "api_base_url"
        value = "https://${azurerm_container_app.backend.ingress[0].fqdn}"
      }

      env {
        name  = "port"
        value = tostring(var.frontend_port)
      }

      env {
        name  = "feature_job_applications"
        value = var.feature_job_applications
      }

      env {
        name  = "feature_role_filtering"
        value = var.feature_role_filtering
      }

      env {
        name  = "feature_ordering_ui"
        value = var.feature_ordering_ui
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = var.frontend_port
    transport        = "auto"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = {
    environment = var.dev_environment
    managed_by  = "terraform"
  }

  depends_on = [
    azurerm_role_assignment.acr_pull,
    azurerm_role_assignment.kv_secrets_user,
  ]
}