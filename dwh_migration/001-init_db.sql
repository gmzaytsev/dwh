create schema dwh_detailed;

create table  dwh_detailed.hub_airports (
    airport_id UUID primary key,
    airport_code char(3) not null,
    load_at timestamp not null,
    record_source text not null,
    unique (airport_code)
);

create table  dwh_detailed.hub_aircrafts (
    aircraft_id UUID primary key,
    aircraft_code char(3) not null,
    load_at timestamp not null,
    record_source text not null,
    unique (aircraft_code)
);

create table dwh_detailed.hub_bookings (
    booking_id UUID primary key,
    booking_reference char(6) not null,
    load_at timestamp not null,
    record_source text not null,
    unique (booking_reference)
);

create table dwh_detailed.hub_tickets (
    ticket_id UUID primary key,
    ticket_number char(13) not null,
    load_at timestamp not null,
    record_source text not null,
    unique (ticket_number)
);

create table  dwh_detailed.hub_flights (
    flight_id UUID primary key,
    flight_number char(6) not null,
    load_at timestamp not null,
    record_source text not null,
    unique (flight_number)
);

-- links


create table dwh_detailed.link_flight_airport (
    flight_id UUID not null,
    departure_airport_id UUID not null,
    arrival_airport_id UUID not null,
    load_at timestamp not null,
    record_source text not null,
    primary key (flight_id, departure_airport_id, arrival_airport_id),
    foreign key (flight_id) references dwh_detailed.hub_flights(flight_id),
    foreign key (departure_airport_id) references dwh_detailed.hub_airports(airport_id),
    foreign key (arrival_airport_id) references dwh_detailed.hub_airports(airport_id)
);

create table dwh_detailed.link_ticket_flight (
    ticket_id UUID not null,
    flight_id UUID not null,
    load_at timestamp not null,
    record_source text not null,
    primary key (ticket_id, flight_id),
    foreign key (ticket_id) references dwh_detailed.hub_tickets(ticket_id),
    foreign key (flight_id) references dwh_detailed.hub_flights(flight_id)
);

create table dwh_detailed.link_ticket_booking (
    ticket_id UUID not null,
    booking_id UUID not null,
    load_at timestamp not null,
    record_source text not null,
    primary key (ticket_id, booking_id),
    foreign key (ticket_id) references dwh_detailed.hub_tickets(ticket_id),
    foreign key (booking_id) references dwh_detailed.hub_bookings(booking_id)
);

create table dwh_detailed.link_flight_aircraft (
    flight_id UUID not null,
    aircraft_id UUID not null,
    load_at timestamp not null,
    record_source text not null,
    primary key (flight_id, aircraft_id),
    foreign key (flight_id) references dwh_detailed.hub_flights(flight_id),
    foreign key (aircraft_id) references dwh_detailed.hub_aircrafts(aircraft_id)
);

-- satelincs

create table dwh_detailed.sat_airports (
    airport_id UUID not null,
    airport_name text,
    airport_code char(3),
    city text,
    longitude decimal,
    latitude decimal,
    timezone text,
    load_at timestamp not null,
    record_source text not null,
    primary key (airport_id, load_at),
    foreign key (airport_id) references dwh_detailed.hub_airports(airport_id)
);

create table dwh_detailed.sat_aircrafts (
    aircraft_id UUID not null,
    model jsonb,
    range integer,
    load_at timestamp not null,
    record_source text not null,
    primary key (aircraft_id, load_at),
    foreign key (aircraft_id) references dwh_detailed.hub_aircrafts(aircraft_id)
);

create table dwh_detailed.sat_flights (
    flight_id UUID not null,
    scheduled_departure timestamptz,
    scheduled_arrival timestamptz,
    status varchar(20),
    aircraft_code char(3),
    actual_departure timestamptz null,
    actual_arrival timestamptz null,
    load_at timestamp not null,
    record_source text not null,
    primary key (flight_id, load_at),
    foreign key (flight_id) references dwh_detailed.hub_flights(flight_id)
);

create table dwh_detailed.sat_tickets (
    ticket_id UUID not null,
    passenger_id varchar(20),
    passenger_name text,
    contact_data jsonb,
    load_at timestamp not null,
    record_source text not null,
    primary key (ticket_id, load_at),
    foreign key (ticket_id) references dwh_detailed.hub_tickets(ticket_id)
);

create table dwh_detailed.sat_bookings (
    booking_id UUID not null,
    booking_date timestamptz,
    total_amount numeric(10, 2),
    load_at timestamp not null,
    record_source text not null,
    primary key (booking_id, load_at),
    foreign key (booking_id) references dwh_detailed.hub_bookings(booking_id)
);
