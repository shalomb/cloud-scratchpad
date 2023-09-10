locals {
  engine = "postgres"
  db_config = {
    preferred_engine_version = jsondecode(file("${path.module}/rds-engine-versions.json"))
    engine_code = {
      mysql        = "MY"
      oracle-ee    = "OR"
      oracle-se2   = "OR"
      sqlserver-ee = "MS"
      sqlserver-se = "MS"
      postgres     = "PS"
      mariadb      = "MD"
    },
  }
}

output "preferred_engine_versions" {
  value = {
    engine  = local.engine
    version = local.db_config.preferred_engine_version[local.engine]
    code    = local.db_config.engine_code[local.engine]
  }
}
