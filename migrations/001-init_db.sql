create table public.airports (
	airport_code char(3) primary key,
	airport_name text not null,
	city text not null,
	coordinates_lon decimal not null, 
	coordinates_lat decimal not null,
	timezone text not null
);

create table public.aircrafts (
	aircraft_code char(3) primary key,
	model jsonb not null,
	range integer not null
);

create table public.seats (
	aircraft_code char(3) references public.aircrafts(aircraft_code),
	seat_no varchar(4),
	fare_conditions varchar(10) not null,
	primary key (aircraft_code, seat_no)
);

create table public.bookings (
	book_ref char(6) primary key,
	book_date timestamptz not null,
	total_amount numeric(10, 2) not null
);

create table public.tickets (
	ticket_no char(13) primary key,
	book_ref char(6) references public.bookings(book_ref),
	passenger_id varchar(20) not null,
	passenger_name text not null,
	contact_data jsonb
);


create table public.flights (
	flight_id serial primary key,
	flight_no char(6) not null,
	scheduled_departure timestamptz not null,
	scheduled_arrival timestamptz not null,
	departure_airport char(3) references public.airports(airport_code),
	arrival_airport char(3) references public.airports(airport_code),
	status varchar(20) not null,
	aircraft_code char(3) references public.aircrafts(aircraft_code),
	actual_departure timestamptz,
	actual_arrival timestamptz
); 

create table public.ticket_flights (
	ticket_no char(13) references public.tickets(ticket_no),
	flight_id integer references public.flights(flight_id),
	fare_conditions numeric(10, 2) not null,
	amount numeric(10, 2) not null,
	primary key (ticket_no, flight_id)
);

create table public.boarding_passes (
	ticket_no char(13) not null,
	flight_id integer not null,
	boarding_no integer not null,
	seat_no varchar(4) not null,
	primary key (ticket_no, flight_id),
	FOREIGN KEY (ticket_no, flight_id) references public.ticket_flights(ticket_no, flight_id)
);
