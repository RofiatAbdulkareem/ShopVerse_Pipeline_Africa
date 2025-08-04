from datetime import datetime

from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.transfers.s3_to_redshift import \
    S3ToRedshiftOperator

from airflow import DAG
from airflow.dags.extract_to_s3 import generate_transaction, upload_to_s3

today_str = datetime.today().strftime("%Y-%m-%d")

# constants
S3_BUCKET = "shopverse-raw"
S3_KEY = f"transactions/{today_str}-tran.parquet"
REDSHIFT_SCHEMA = "public"
REDSHIFT_TABLE = "transactions"
REDSHIFT_CONN_ID = "redshift"
AWS_CONN_ID = "aws_default"

default_args = {
    'owner': 'rofiat',
    'retries': 1,
    'start_date': datetime(2025, 7, 25),
}

dag = DAG(
    dag_id="shopverse_africa",
    description="Simulates and loads shopverse \
        transactional data to Redshift daily",
    default_args=default_args,
    schedule_interval="@daily",
    catchup=False,
)

generate_transaction_data = PythonOperator(
    task_id="generate_transaction_data",
    python_callable=generate_transaction,
    dag=dag
)

write_to_s3 = PythonOperator(
    task_id="upload_to_s3",
    python_callable=upload_to_s3,
    dag=dag
)

s3_to_redshift = S3ToRedshiftOperator(
    task_id="s3_to_redshift",
    schema=REDSHIFT_SCHEMA,
    table=REDSHIFT_TABLE,
    s3_bucket=S3_BUCKET,
    s3_key=S3_KEY,
    copy_options=["FORMAT AS PARQUET"],
    redshift_conn_id=REDSHIFT_CONN_ID,
    aws_conn_id=AWS_CONN_ID,
    dag=dag
)

generate_transaction_data >> write_to_s3 >> s3_to_redshift
