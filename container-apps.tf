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
        name  = "POSTGRES-USER"
        value = var.postgres_user
      }

      env {
        name        = "POSTGRES-PASSWORD"
        secret_name = "POSTGRES-PASSWORD"
      }

      env {
        name  = "POSTGRES-DB"
        value = var.postgres_db
      }
    }
  }

  secret {
    name                = "POSTGRES-PASSWORD"
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
        name        = "DATABASE-URL"
        secret_name = "DATABASE-URL"
      }

      env {
        name  = "SCHEMA-NAME"
        value = var.schema_name
      }

      env {
        name        = "JWT-SECRET"
        secret_name = "JWT-SECRET"
      }

      env {
        name  = "CORS_ORIGIN"
        value = var.cors_origin != "" ? var.cors_origin : "https://ca-frontend-${var.dev_environment}.${azurerm_container_app_environment.container_app_environment.default_domain}"
      }

      env {
        name  = "PORT"
        value = tostring(var.backend_port)
      }

      env {
        name  = "AWS_REGION"
        value = var.aws_region
      }

      env {
        name        = "AWS-ACCESS-KEY-ID"
        secret_name = "AWS-ACCESS-KEY-ID"
      }

      env {
        name        = "AWS-SECRET-ACCESS-KEY"
        secret_name = "AWS-SECRET-ACCESS-KEY"
      }

      env {
        name  = "S3_BUCKET_NAME"
        value = var.s3_bucket_name
      }
    }
  }

  secret {
    name                = "DATABASE-URL"
    key_vault_secret_id = data.azurerm_key_vault_secret.database_url.versionless_id
    identity            = azurerm_user_assigned_identity.managed_identity.id
  }

  secret {
    name                = "JWT-SECRET"
    key_vault_secret_id = data.azurerm_key_vault_secret.jwt_secret.versionless_id
    identity            = azurerm_user_assigned_identity.managed_identity.id
  }

  secret {
    name                = "AWS-ACCESS-KEY-ID"
    key_vault_secret_id = data.azurerm_key_vault_secret.aws_access_key_id.versionless_id
    identity            = azurerm_user_assigned_identity.managed_identity.id
  }

  secret {
    name                = "AWS-SECRET-ACCESS-KEY"
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
        name  = "API_BASE_URL"
        value = "https://${azurerm_container_app.backend.ingress[0].fqdn}"
      }

      env {
        name  = "PORT"
        value = tostring(var.frontend_port)
      }

      env {
        name  = "FEATURE_JOB_APPLICATIONS"
        value = var.feature_job_applications
      }

      env {
        name  = "FEATURE_ROLE_FILTERING"
        value = var.feature_role_filtering
      }

      env {
        name  = "FEATURE_ORDERING_UI"
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