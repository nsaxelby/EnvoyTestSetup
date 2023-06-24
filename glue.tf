resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = "my-glue-catalog"
}


resource "aws_glue_catalog_table" "my_envoy_record_table" {
  name          = "envoy"
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
  table_type    = "EXTERNAL_TABLE"
  storage_descriptor {
    schema_reference {
      schema_id {
        schema_arn = aws_glue_schema.envoy_record_schema.arn
      }
      schema_version_number = aws_glue_schema.envoy_record_schema.latest_schema_version
    }
  }
}

resource "aws_glue_registry" "my-schema-registry" {
  registry_name = "my-schema-registry"
}

resource "aws_glue_schema" "envoy_record_schema" {
  schema_name       = "envoy-record-schema"
  registry_arn      = aws_glue_registry.my-schema-registry.arn
  data_format       = "JSON"
  compatibility     = "NONE"
  schema_definition = "{\n\t\"definitions\": {},\n\t\"$schema\": \"http://json-schema.org/draft-07/schema#\", \n\t\"$id\": \"https://example.com/object1687610789.json\", \n\t\"title\": \"Root\", \n\t\"type\": \"object\",\n\t\"required\": [\n\t\t\"request_time\",\n\t\t\"remote_ip\",\n\t\t\"response_code\"\n\t],\n\t\"properties\": {\n\t\t\"request_time\": {\n\t\t\t\"$id\": \"#root/request_time\", \n\t\t\t\"title\": \"Request_time\", \n\t\t\t\"type\": \"string\",\n\t\t\t\"default\": \"\",\n\t\t\t\"examples\": [\n\t\t\t\t\"2023-06-24T11:52:40.403Z\"\n\t\t\t],\n\t\t\t\"pattern\": \"^.*$\"\n\t\t},\n\t\t\"remote_ip\": {\n\t\t\t\"$id\": \"#root/remote_ip\", \n\t\t\t\"title\": \"Remote_ip\", \n\t\t\t\"type\": \"string\",\n\t\t\t\"default\": \"\",\n\t\t\t\"examples\": [\n\t\t\t\t\"109.155.64.252\"\n\t\t\t],\n\t\t\t\"pattern\": \"^.*$\"\n\t\t},\n\t\t\"response_code\": {\n\t\t\t\"$id\": \"#root/response_code\", \n\t\t\t\"title\": \"Response_code\", \n\t\t\t\"type\": \"integer\",\n\t\t\t\"examples\": [\n\t\t\t\t200\n\t\t\t],\n\t\t\t\"default\": 0\n\t\t}\n\t}\n}\n"
}
