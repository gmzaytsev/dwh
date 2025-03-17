import os
from datetime import datetime, timedelta

from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator

sql_script_1 = '''
    create table if not exists presentation.airport_passenger_flow (
        created_at timestamp default CURRENT_TIMESTAMP,
        flight_date date not null,
        airport_code char(3) not null,
        linked_airport_code char(3) not null,
        flights_in int not null,
        flights_out int not null,
        passengers_in int not null,
        passengers_out int not null
    );
'''

sql_delete_data = '''
     delete from presentation.airport_passenger_flow
     where date(created_at) = DATE(now())-1;
'''


DEFAULT_ARGS = {
    'owner': 'gmzaytsev&vsvasina',
    'depends_on_past': False,
    'start_date': datetime(2025, 3, 17),
    'email': None,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=5),
    'execution_timeout': timedelta(minutes=120)
}

with DAG("traffic_airport_dag",
         default_args=DEFAULT_ARGS,
         catchup=False,
         schedule_interval="0 7 * * *",
         max_active_runs=1,
         concurrency=1) as dag:
    
    # 1 - Create schema
    task1 = PostgresOperator(
        task_id="create_schema",
        postgres_conn_id="postgres_master",
        sql=sql_script_1,
    )

    # 2 - delete data
    task2 = PostgresOperator(
        task_id="delete_data",
        postgres_conn_id="postgres_master",
        sql=sql_delete_data,
    )

    task1 >> task2