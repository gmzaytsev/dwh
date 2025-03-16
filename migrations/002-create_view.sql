create view airport_flight_info as
with airports_departure_flights as (
    select
        departure_airport as airport_code,
        COUNT(*) as departure_flights_num
    from flights
    group by departure_airport
),
airports_departure_passengers as (
    select
        flights.departure_airport as airport_code,
        COUNT(distinct ticket_flights.ticket_no) as departure_psngr_num
    from flights
    join ticket_flights on flights.flight_id = ticket_flights.flight_id
    group by flights.departure_airport
),
airports_arrival_flights as (
    select
        arrival_airport as airport_code,
        COUNT(*) as arrival_flights_num
    from flights
    group by arrival_airport
),
airports_arrival_passengers as (
    select
        flights.arrival_airport as airport_code,
        COUNT(distinct ticket_flights.ticket_no) as arrival_psngr_num
    from flights
    JOIN ticket_flights on flights.flight_id = ticket_flights.flight_id
    group by flights.arrival_airport
)
select
    airports.airport_code,
    COALESCE(adf.departure_flights_num, 0) as departure_flights_num,
    COALESCE(adp.departure_psngr_num, 0) as departure_psngr_num,
    COALESCE(aaf.arrival_flights_num, 0) as arrival_flights_num,
    COALESCE(aap.arrival_psngr_num, 0) as arrival_psngr_num
from
    airports
left join airports_departure_flights adf on airports.airport_code = adf.airport_code
left join airports_departure_passengers adp on airports.airport_code = adp.airport_code
left join airports_arrival_flights aaf on airports.airport_code = aaf.airport_code
left join airports_arrival_passengers aap on airports.airport_code = aap.airport_code;
