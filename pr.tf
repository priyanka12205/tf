provider "aws" {
  region = "us-east-1"
}

# 1️⃣ Glue Catalog Database
resource "aws_glue_catalog_database" "etl_db" {
  name = "manual-etl-db"  # ✅ lowercase and hyphen only
}

# 2️⃣ IAM Role for Glue
resource "aws_iam_role" "glue_service_role" {
  name = "glue_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "glue.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# 3️⃣ IAM Policy Attachment
resource "aws_iam_role_policy" "glue_policy" {
  name = "glue-etl-policy"
  role = aws_iam_role.glue_service_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::prj3",
          "arn:aws:s3:::prj3/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "glue:*",
          "logs:*"
        ],
        Resource = "*"
      }
    ]
  })
}

# 4️⃣ Glue Crawler
resource "aws_glue_crawler" "etl_crawler" {
  name = "manual-etl-crawler"
  role = aws_iam_role.glue_service_role.arn

  database_name = aws_glue_catalog_database.etl_db.name

  s3_target {
    path = "s3://prj3/data/"
  }

  schedule = "cron(0 12 * * ? *)"  # daily at 12:00 UTC

  schema_change_policy {
    delete_behavior  = "LOG"
    update_behavior  = "UPDATE_IN_DATABASE"
  }
}

# 5️⃣ Glue Job
resource "aws_glue_job" "etl_job" {
  name     = "manual-etl-job"
  role_arn = aws_iam_role.glue_service_role.arn

  command {
    name            = "glueetl"
     script_location = "s3://prj3/p123.py"
    python_version  = "3"
  }

  glue_version      = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  execution_property {
    max_concurrent_runs = 1
  }

  timeout = 10

  default_arguments = {
    "--job-language"                      = "python"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-glue-datacatalog"          = "true"
    "--TempDir"                           = "s3://prj3"
  }
}

# 6️⃣ Outputs
output "glue_job_name" {
  value = aws_glue_job.etl_job.name
}

output "glue_crawler_name" {
  value = aws_glue_crawler.etl_crawler.name
}

output "iam_role_arn" {
  value = aws_iam_role.glue_service_role.arn
}
