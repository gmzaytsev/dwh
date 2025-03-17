import os
from datetime import datetime, timedelta

from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator

sql_create_table = '''
    create table if not exists presentation.frequent_flyer
    (
        created_at          timestamp default CURRENT_TIMESTAMP,
        passenger_id        varchar(200) not null,
        passenger_name      text not null,
        flights_number      int not null,
        purchase_sum        numeric(10, 2) not null,
        home_airport        char(3) not null,
        customer_group      char(3) not null
    );
'''

sql_delete_data = '''
     DELETE FROM presentation.frequent_flyer;
'''

sql_insert_data = '''
            WITH flights_data AS (
                SELECT
                    t.passenger_id,
                    t.passenger_name,
                    COUNT(tf.flight_id) AS flights_number,
                    SUM(tf.amount) AS purchase_sum
                from tickets t
                join ticket_flights tf ON t.ticket_no = tf.ticket_no
                join flights f ON tf.flight_id = f.flight_id
                group by t.passenger_id, t.passenger_name
            ),
            home_airport_data as (
                SELECT
                    t.passenger_id,
                    FIRST_VALUE(f.departure_airport) OVER (
                        partition by t.passenger_id 
                        order by COUNT(*) DESC, f.departure_airport
                    ) as home_airport
                from tickets t
                join ticket_flights tf ON t.ticket_no = tf.ticket_no
                join flights f ON tf.flight_id = f.flight_id
                group by t.passenger_id, f.departure_airport
            ),
            flights_data_with_percentile AS (
                select
                    passenger_id,
                    100 * percent_rank() OVER (ORDER BY SUM(purchase_sum) DESC) AS percentile
                from flights_data
                GROUP BY passenger_id
            )
            insert into presentation.frequent_flyer (
                passenger_id, passenger_name, flights_number, purchase_sum, home_airport, customer_group
            )
            SELECT
                fd.passenger_id,
                fd.passenger_name,
                fd.flights_number,
                fd.purchase_sum,
                had.home_airport,
                CASE
                    WHEN fdwp.percentile <= 5 THEN '5'
                    WHEN fdwp.percentile <= 10 THEN '10'
                    WHEN fdwp.percentile <= 25 THEN '25'
                    WHEN fdwp.percentile <= 50 THEN '50'
                    ELSE '50+'
                END AS customer_group
            FROM (
                SELECT
                    passenger_id,
                    passenger_name,
                    COUNT(flights_number) AS flights_number,
                    SUM(purchase_sum) AS purchase_sum
                FROM flights_data
                GROUP BY passenger_id, passenger_name
            ) AS fd
            LEFT JOIN home_airport_data had ON fd.passenger_id = had.passenger_id
            LEFT JOIN flights_data_with_percentile fdwp ON fd.passenger_id = fdwp.passenger_id
            ;
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

with DAG("frequent_flyer_dag",
         default_args=DEFAULT_ARGS,
         catchup=False,
         schedule_interval="0 7 * * *",
         max_active_runs=1,
         concurrency=1) as dag:
    
    # 1 - Create schema
    task1 = PostgresOperator(
        task_id="create_table",
        postgres_conn_id="postgres_master",
        sql=sql_create_table,
    )

    # 3 - drop data
    task2 = PostgresOperator(
        task_id="drop_data",
        postgres_conn_id="postgres_master",
        sql=sql_delete_data,
    )
    
    # 3 - insert data
    task3 = PostgresOperator(
        task_id="insert_data",
        postgres_conn_id="postgres_master",
        sql=sql_insert_data,
    )

    task1 >> task2 >> task3