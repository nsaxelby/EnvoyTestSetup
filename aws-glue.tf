# resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
#   name = aws_glue_catalog_database.aws_glue_catalog_database.name

#   create_table_default_permission {
#     permissions = ["SELECT"]

#     principal {
#       data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
#     }
#   }
# }

# resource "aws_glue_catalog_table" "aws_glue_catalog_envoy_access_log_table" {
#   name          = "envoy-access-log-table"
#   database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
# }
