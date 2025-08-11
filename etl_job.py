import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue import DynamicFrame

def sparkSqlQuery(glueContext, query, mapping, transformation_ctx) -> DynamicFrame:
    for alias, frame in mapping.items():
        frame.toDF().createOrReplaceTempView(alias)
    result = spark.sql(query)
    return DynamicFrame.fromDF(result, glueContext, transformation_ctx)
args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Script generated for node Amazon S3
AmazonS3_node1752689308308 = glueContext.create_dynamic_frame.from_options(format_options={}, connection_type="s3", format="parquet", connection_options={"paths": ["s3://stagingbucketp/financial_data_staging/part-00000-170b9c68-df59-420a-a943-69b4b915437e-c000.snappy.parquet"], "recurse": True}, transformation_ctx="AmazonS3_node1752689308308")

# Script generated for node SQL Query
SqlQuery2253 = '''
select max(profit) from myDataSource
'''
SQLQuery_node1752689469383 = sparkSqlQuery(glueContext, query = SqlQuery2253, mapping = {"myDataSource":AmazonS3_node1752689308308}, transformation_ctx = "SQLQuery_node1752689469383")

# Script generated for node MySQL
MySQL_node1752689567930 = glueContext.write_dynamic_frame.from_catalog(frame=SQLQuery_node1752689469383, database="finanicaldata", table_name="financial_data_staging", transformation_ctx="MySQL_node1752689567930")

job.commit()