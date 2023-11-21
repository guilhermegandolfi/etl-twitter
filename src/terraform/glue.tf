resource "aws_glue_catalog_database" "aws_glue_catalog_database_bronze_data" {
  name = "star_wars_bronze_data"
}

resource "aws_glue_catalog_database" "aws_glue_catalog_database_silver_data" {
  name = "star_wars_silver_data"
}

resource "aws_glue_catalog_database" "aws_glue_catalog_database_gold_data" {
  name = "star_wars_gold_data"
}

resource "aws_glue_crawler" "aws_glue_crawler_bronze_Data" {
  database_name = aws_glue_catalog_database.aws_glue_catalog_database_bronze_data.name
  name          = "glue_crawler_${aws_glue_catalog_database.aws_glue_catalog_database_bronze_data.name}"
  role          = aws_iam_role.aws_iam_role_glue.arn
  delta_target {
    delta_tables = ["s3://${aws_s3_bucket.bucket_s3.id}/bronze_data/films", 
    "s3://${aws_s3_bucket.bucket_s3.id}/bronze_data/people", 
    "s3://${aws_s3_bucket.bucket_s3.id}/bronze_data/planets", 
    "s3://${aws_s3_bucket.bucket_s3.id}/bronze_data/species", 
    "s3://${aws_s3_bucket.bucket_s3.id}/bronze_data/starships", 
    "s3://${aws_s3_bucket.bucket_s3.id}/bronze_data/vehicles"
    ]
    write_manifest = false
  }
  tags = var.tags
}

