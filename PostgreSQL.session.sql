-------------------------- CREATE TABLES --------------------------------------------

CREATE OR REPLACE PROCEDURE CreateAllTables()
LANGUAGE plpgsql
AS $$
BEGIN

CREATE TABLE Users(
    userID INT GENERATED ALWAYS AS IDENTITY,
    email VARCHAR(50) UNIQUE,
    password VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender VARCHAR(50),
    country VARCHAR(50) NOT NULL,
    age INT NOT NULL,
    currency VARCHAR(50) NOT NULL,
    Constraint Users_PK PRIMARY KEY (userID)
);

CREATE TABLE Trip(      --18
    trip_id INT GENERATED ALWAYS AS IDENTITY,       --64
    purpose VARCHAR(100),       --89
    city VARCHAR(50),
    country VARCHAR(50),
    region VARCHAR(50),
    budget INT,     --104
    start_date DATE,        --124
    end_date DATE,      --142
    duration INT GENERATED ALWAYS AS (end_date - start_date) STORED,      --204
    userID INT,       --220
    CONSTRAINT Trip_PK PRIMARY KEY (trip_id),      --265
    CONSTRAINT Trip_FK FOREIGN KEY (userID) REFERENCES Users(userID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Destination(
    destination_id INT GENERATED ALWAYS AS IDENTITY,
    region VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    description VARCHAR(1000),
    CONSTRAINT Destination_PK PRIMARY KEY (destination_id)
);

CREATE TABLE Day(
    trip_id INT,
    date DATE,
    CONSTRAINT Day_PK PRIMARY KEY (trip_id, date),
    CONSTRAINT Day_FK FOREIGN KEY (trip_id) REFERENCES Trip(trip_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Attraction(
    attraction_id INT GENERATED BY DEFAULT AS IDENTITY,
    name VARCHAR(100),
    description VARCHAR(1000),
    location VARCHAR(200),
    price FLOAT,
    rating FLOAT,
    opening_time TIME,
    closing_time TIME,
    type VARCHAR(50),
    destination_id INT,
    CONSTRAINT Attraction_PK PRIMARY KEY (attraction_id),
    CONSTRAINT Attraction_FK FOREIGN KEY (destination_id) REFERENCES Destination(destination_id)
);

CREATE TABLE TransportationPlan(
    plan_id INT GENERATED ALWAYS AS IDENTITY,
    departure_city VARCHAR(100),
    arrival_city VARCHAR(100),
    trip_id INT,
    CONSTRAINT TransportationPlan_PK PRIMARY KEY (plan_id),
    CONSTRAINT TransportationPlan_FK FOREIGN KEY (trip_id) REFERENCES Trip(trip_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Transportation(
    transportation_id INT GENERATED ALWAYS AS IDENTITY,
    arrival_time TIMESTAMP,
    departure_time TIMESTAMP ,
    price FLOAT,
    departure_point VARCHAR(100),
    arrival_point VARCHAR(100),
    duration INTERVAL GENERATED ALWAYS AS (arrival_time - departure_time) STORED,
    CONSTRAINT Transportation_PK PRIMARY KEY (transportation_id)
);


CREATE TABLE Flight(
    flight_number VARCHAR(20),
    connecting_direct BIT,      --connecting 1, direct 0
    airline_name VARCHAR(50),
    terminal INT,
    transportation_id INT,
    CONSTRAINT Flight_PK PRIMARY KEY (transportation_id, flight_number),
    CONSTRAINT Flight_FK FOREIGN KEY (transportation_id) REFERENCES Transportation(transportation_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Train(
    train_number VARCHAR(20),
    connecting_direct BIT,      --connecting 1, direct 0
    railway_company VARCHAR(100),
    platform INT,
    transportation_id INT,
    CONSTRAINT Train_PK PRIMARY KEY (transportation_id, train_number),
    CONSTRAINT Train_FK FOREIGN KEY (transportation_id) REFERENCES Transportation(transportation_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Bus(
    bus_number VARCHAR(20),
    bus_company VARCHAR(50),
    transportation_id INT,
    CONSTRAINT Bus_PK PRIMARY KEY (transportation_id, bus_number),
    CONSTRAINT Bus_FK FOREIGN KEY (transportation_id) REFERENCES Transportation(transportation_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE TransportationPlanTrips(
    plan_id INT,
    transportation_id INT,
    CONSTRAINT TransPlanTrips_PK PRIMARY KEY (transportation_id, plan_id),
    CONSTRAINT TransPlanTrips_PlanFK FOREIGN KEY (plan_id) REFERENCES TransportationPlan(plan_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT TransPlanTrips_TransFK FOREIGN KEY (transportation_id) REFERENCES Transportation(transportation_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Trip_Transportation(
    trip_id INT,
    plan_id INT,
    CONSTRAINT TripTrans_PK PRIMARY KEY (trip_id, plan_id),
    CONSTRAINT TripTrans_PlanFK FOREIGN KEY (plan_id) REFERENCES TransportationPlan(plan_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT TripTrans_TripFK FOREIGN KEY (trip_id) REFERENCES Trip(trip_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Hotel(
    hotel_id INT GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(50),
    location VARCHAR(200),
    price FLOAT,
    rating FLOAT,
    CONSTRAINT Hotel_PK PRIMARY KEY (hotel_id)
);

CREATE TABLE Trip_Hotel(
    trip_id INT,
    hotel_id INT,
    CONSTRAINT TripHotel_PK PRIMARY KEY (trip_id, hotel_id),
    CONSTRAINT TripHotel_HotelFK FOREIGN KEY (hotel_id) REFERENCES Hotel(hotel_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT TripHotel_TripFK FOREIGN KEY (trip_id) REFERENCES Trip(trip_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE TripInterests(
    trip_id INT,
    interest VARCHAR(50),
    CONSTRAINT TripInterests_PK PRIMARY KEY (trip_id, interest),
    CONSTRAINT TripInterests_FK FOREIGN KEY (trip_id) REFERENCES Trip(trip_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Trip_Destinations(
    trip_id INT,
    destination_id INT,
    city_from VARCHAR(50),
    country_from VARCHAR(50),
    -- city_to VARCHAR(50),
    -- country_to VARCHAR(50),
    start_date DATE,
    end_date DATE,
    duration INT GENERATED ALWAYS AS (end_date - start_date) STORED,
    CONSTRAINT TripDest_PK PRIMARY KEY (trip_id, destination_id),
    CONSTRAINT TripDest_DestFK FOREIGN KEY (destination_id) REFERENCES Destination(destination_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT TripDest_TripFK FOREIGN KEY (trip_id) REFERENCES Trip(trip_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Restaurant(
    restaurant_id INT GENERATED ALWAYS AS IDENTITY,
    location VARCHAR(100),
    name VARCHAR(50),
    rating FLOAT,
    description VARCHAR(1000),
    avg_price FLOAT,
    opening_time TIME,
    closing_time TIME,
    CONSTRAINT Restaurant_PK PRIMARY KEY (restaurant_id)
);

CREATE TABLE Day_Restaurant(
    restaurant_id INT,
    trip_id INT,
    date DATE,
    meal VARCHAR(50),
    start_time TIME,
    end_time TIME,
    CONSTRAINT DayRest_PK PRIMARY KEY (trip_id, date, start_time, end_time),
    CONSTRAINT DayRest_RestFK FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT DayRest_DayFK FOREIGN KEY (trip_id, date) REFERENCES Day(trip_id, date) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Day_Activities(
    trip_id INT,
    date DATE,
    attraction_id INT,
    start_time TIME,
    end_time TIME, 
    --UNIQUE (trip_id, date, start_time, end_time),
    CONSTRAINT Activity_PK PRIMARY KEY (trip_id, date, start_time, end_time),
    CONSTRAINT Activity_AttrFK FOREIGN KEY (attraction_id) REFERENCES Attraction(attraction_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Activity_DayFK FOREIGN KEY (trip_id, date) REFERENCES Day(trip_id, date) ON DELETE CASCADE ON UPDATE CASCADE
);

--drop Table Day_Activities


CREATE TABLE Attraction_Rating(
    userID INT,
    attraction_id INT,
    rating FLOAT,
    CONSTRAINT AttrRating_PK PRIMARY KEY (userID, attraction_id),
    CONSTRAINT AttrRating_AttrFK FOREIGN KEY (attraction_id) REFERENCES Attraction(attraction_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT AttrRating_UserFK FOREIGN KEY (userID) REFERENCES Users(userID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Hotel_Rating(
    userID INT,
    hotel_id INT,
    rating FLOAT,
    CONSTRAINT HotelRating_PK PRIMARY KEY (userID, hotel_id),
    CONSTRAINT HotelRating_HotelFK FOREIGN KEY (hotel_id) REFERENCES Hotel(hotel_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT HotelRating_UserFK FOREIGN KEY (userID) REFERENCES Users(userID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Restaurant_Rating(
    userID INT,
    restaurant_id INT,
    rating FLOAT,
    CONSTRAINT RestRating_PK PRIMARY KEY (userID, restaurant_id),
    CONSTRAINT RestRating_RestFK FOREIGN KEY(restaurant_id) REFERENCES Restaurant(restaurant_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT RestRating_UserFK FOREIGN KEY (userID) REFERENCES Users(userID) ON DELETE CASCADE ON UPDATE CASCADE
);

END $$
--------------------------------------------------------------------------------


-------------------------------------- DROP TABLES --------------------------------------------

CREATE OR REPLACE PROCEDURE DropAllTables()
LANGUAGE plpgsql
AS $$
BEGIN

DROP TABLE TransportationPlanTrips;
DROP TABLE Trip_Transportation;
DROP TABLE Trip_Hotel;
DROP TABLE TripInterests;
DROP TABLE Trip_Destinations;
DROP TABLE Day_Restaurant;
DROP TABLE Day_Activities;
DROP TABLE Attraction_Rating;
DROP TABLE Hotel_Rating;
DROP TABLE Restaurant_Rating;
DROP TABLE Flight;
DROP TABLE Train;
DROP TABLE Bus;
DROP TABLE Transportation;
DROP TABLE TransportationPlan;
DROP TABLE Attraction;
DROP TABLE Destination;
DROP TABLE Hotel;
DROP TABLE Restaurant;
DROP TABLE Day;
DROP TABLE Trip;
DROP TABLE Users;

END $$

----------------------------------------------------------------------------------------------------

CALL DropAllTables()

-------------------------------------- CLEAR TABLES --------------------------------------------

CREATE OR REPLACE PROCEDURE ClearAllTables()
LANGUAGE plpgsql
AS $$
BEGIN

DELETE FROM TransportationPlanTrips;
DELETE FROM  Trip_Transportation;
DELETE FROM  Trip_Hotel;
DELETE FROM TripInterests;
DELETE FROM Trip_Destinations;
DELETE FROM Day_Restaurant;
DELETE FROM Day_Activities;
DELETE FROM Attraction_Rating;
DELETE FROM Hotel_Rating;
DELETE FROM Restaurant_Rating;
DELETE FROM Flight;
DELETE FROM Train;
DELETE FROM Bus;
DELETE FROM Transportation;
DELETE FROM TransportationPlan;
DELETE FROM Destination;
DELETE FROM Attraction;
DELETE FROM Hotel;
DELETE FROM Restaurant;
DELETE FROM Day;
DELETE FROM Trip;
DELETE FROM Users;

END $$

----------------------------------------------------------------------------------------------------


-------------------------------------------- ADD PROCEDURES ----------------------------------------

CREATE OR REPLACE PROCEDURE addUser (email VARCHAR(50), password VARCHAR(50), 
    first_name VARCHAR(50), last_name VARCHAR(50), 
    age INT, gender VARCHAR(20),
    country VARCHAR(50), currency VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Users (email, password, first_name, last_name, gender, country, age, currency) VALUES (email, password, first_name, last_name, gender, country, age, currency);
END $$

--drop PROCEDURE addUser

-- CALL addUser('zeinahezzah@gmail.com', 'zeinahezzah', 'Zeina', 'Hezzah', 21, 'Female', 'Egypt', 'EGP')

-- CALL addUser('arwahezzah@gmail.com', 'arwahezzah', 'Arwa', 'Hezzah', 25, 'Female', 'Egypt', 'EGP')

--SELECT * FROM Users

--DELETE FROM Users

-----------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE addTrip (u_email VARCHAR(50), purpose VARCHAR(50), region VARCHAR(50), 
    budget INT, start_date DATE, end_date DATE
)
LANGUAGE plpgsql
AS $$
DECLARE 
u_id INT;
tripID INT;
i DATE := start_date;
BEGIN
    SELECT userID INTO u_id FROM Users WHERE email = u_email;
    INSERT INTO Trip (purpose, budget, region, start_date, end_date, userID) VALUES (purpose, budget, region, start_date, end_date, u_id) 
        returning trip_id INTO tripID;

    --DECLARE i DATE := start_date;
    WHILE i <= end_date loop
        CALL addDay(tripID, i);
        i := i + 1;
    END loop;
END $$

-- drop PROCEDURE addTrip

-- CALL addTrip('zeinahezzah@gmail.com', 'vacation', 10000, '2023-08-03', '2023-08-10')

-- SELECT * FROM Trip
-- SELECT * FROM Day

-- DELETE FROM Trip

--------------------------------------------------------------------------------------------


CREATE OR REPLACE PROCEDURE addDestination (city VARCHAR(50), country VARCHAR(50), region VARCHAR(50),
   description VARCHAR(1000)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Destination (city, country, region, description) VALUES (city, country, region, description) ;
END $$

--drop PROCEDURE addDestination

-- CALL addDestination('Barcelona', 'Spain', 'Europe','hot city')

--SELECT * FROM Destination

--DELETE FROM Destination

-----------------------------------------------------------------------------------------------

--FOR TRIP WITH ONE DESTINATION SELECTED FROM BEGINNING

CREATE OR REPLACE PROCEDURE addTripWithDestination(u_email VARCHAR(50), purpose VARCHAR(50), budget INT, 
        start_date DATE, end_date DATE, city_to VARCHAR(50), country_to VARCHAR(50), 
        city_from VARCHAR(50), country_from VARCHAR(50)
    )
LANGUAGE plpgsql
AS $$
DECLARE 
u_id INT;
dest_id INT; 
t_id INT;
i DATE := start_date;

BEGIN
    SELECT userID into u_ID FROM Users WHERE email = u_email;
    SELECT destination_id INTO dest_id FROM Destination WHERE city_to = city AND country_to = country;
    INSERT INTO Trip (purpose, budget, start_date, end_date, userID) VALUES (purpose, budget, start_date, end_date, u_ID)
        returning trip_id INTO t_id ;
    INSERT INTO Trip_Destinations (trip_id, destination_id, city_from, country_from, start_date, end_date) VALUES (t_id, dest_id, city_from, country_from, start_date, end_date);

   -- DECLARE i DATE := start_date;
    WHILE i <= end_date loop
        CALL addDay(t_id, i);
        i := i + 1;
    END loop;

END $$

drop PROCEDURE addTripWithDestination

CALL addTripWithDestination('zeinahezzah@gmail.com', 'vacation', 10000, '2023-08-03', '2023-08-10', 'Barcelona', 'Spain', 'Paris', 'France')

-- SELECT * FROM Trip;
-- SELECT * FROM Destination;
-- SELECT * FROM Trip_Destinations;
-- SELECT * FROM Day

-- DELETE FROM Trip;
-- DELETE FROM Trip_Destinations;
-- DELETE FROM Day;

------------------------------------------------------------------------------------


CREATE OR REPLACE PROCEDURE addDay (trip_id INT, date DATE)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Day (trip_id, date) VALUES (trip_id, date);
END $$

-- drop PROCEDURE addDay;

-- CALL addDay(9, '2023-08-03');

-- SELECT * FROM Day;

-- DELETE FROM Day;

----------------------------------------------------------------


CREATE OR REPLACE PROCEDURE addAttraction (name VARCHAR(100), description VARCHAR(1000), 
    location VARCHAR(200), a_city VARCHAR(50), a_country VARCHAR(50), price FLOAT, rating FLOAT,
    opening_time TIME, closing_time TIME, type VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
dest_id INT;
BEGIN
    SELECT destination_id INTO dest_id FROM Destination WHERE a_city = city AND a_country = country;
    INSERT INTO Attraction (name, description, location, price, rating, opening_time, closing_time, type, destination_id) VALUES (name, description, location, price, rating, opening_time, closing_time, type, dest_id);
END $$

--drop PROCEDURE addAttraction

CALL addAttraction('Disney Land', 'a great place with rides and food', '142 Charles de Gaulle Rue', 'Paris', 'France', 25.0, 4.8, '08:00:00', '20:00:00', 'Entertainment');

-- SELECT * FROM Attraction

--DELETE FROM Attraction


------------------------------------------------------------------------------

-- SELECT 'DROP PROCEDURE ' || oid::regprocedure
-- FROM pg_proc
-- WHERE proname = 'adddestination'
-- AND pg_function_is_visible(oid);



--------------------------------------------------------------------------------


CREATE OR REPLACE PROCEDURE addTransportationPlan (dep_city VARCHAR(50), arrival_city VARCHAR(50), trip_id INT)
LANGUAGE plpgsql
AS $$
DECLARE 
planID INT;
BEGIN
    INSERT INTO TransportationPlan (departure_city, arrival_city, trip_id) VALUES (dep_city, arrival_city, trip_id)
        returning plan_id INTO planID;

    INSERT INTO Trip_Transportation VALUES (trip_id, planID);
END $$

-- drop PROCEDURE addTransportationPlan;

-- CALL addTransportationPlan('Paris', 'Barcelona', 9);

-- SELECT * FROM TransportationPlan;
-- SELECT * FROM Trip_Transportation;

-- DELETE FROM TransportationPlan;

---------------------------------------------------------------------------


CREATE OR REPLACE PROCEDURE addFlight (flightNo VARCHAR(20), airline VARCHAR(50), terminal INT, 
        departure_time TIMESTAMP, arrival_time TIMESTAMP, 
        price FLOAT, connecting_direct BIT, departure_airport VARCHAR(100), arrival_airport VARCHAR(100)
 )
LANGUAGE plpgsql
AS $$
DECLARE
trans_id INT;

BEGIN
    INSERT INTO Transportation (arrival_time, departure_time, price, departure_point, arrival_point) VALUES 
            (arrival_time, departure_time, price, departure_airport, arrival_airport) returning transportation_id INTO trans_id;
    INSERT INTO Flight (flight_number, connecting_direct, airline_name, terminal, transportation_id) VALUES
            (flightNo, connecting_direct, airline, terminal, trans_id);

END $$

-- drop PROCEDURE addFlight;

-- CALL addFlight('MS736', 'EgyptAir', 2, '2023-08-03 10:00:00', '2023-08-03 14:00:00', 25324.33, '0', 'Cairo Airport', 'Charles de Gaulle Airport') ;

-- SELECT * FROM Flight;
-- SELECT * FROM Transportation;

-- DELETE FROM Transportation;


---------------------------------------------------------------------------------------------


CREATE OR REPLACE PROCEDURE addTrain (trainNo VARCHAR(20), railway_company VARCHAR(50), platform INT, 
        departure_time TIMESTAMP, arrival_time TIMESTAMP, 
        price FLOAT, connecting_direct BIT, departure_station VARCHAR(100), arrival_station VARCHAR(100)
 )
LANGUAGE plpgsql
AS $$
DECLARE
trans_id INT;

BEGIN
    INSERT INTO Transportation (arrival_time, departure_time, price, departure_point, arrival_point) VALUES 
            (arrival_time, departure_time, price, departure_station, arrival_station) returning transportation_id INTO trans_id;
    INSERT INTO Train (train_number, connecting_direct, railway_company, platform, transportation_id) VALUES
            (trainNo, connecting_direct, railway_company, platform, trans_id);

END $$

-- drop PROCEDURE addTrain;

-- CALL addTrain('EG2834', 'Egypt Railways', 9, '2023-08-04 21:00:00', '2023-08-05 02:00:00', 8352.20, '1', 'Cairo Station', 'Aswan Station') ;

-- SELECT * FROM Train;
-- SELECT * FROM Transportation;

-- DELETE FROM Transportation;

---------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE addBus (busNo VARCHAR(20), bus_company VARCHAR(50), 
        departure_time TIMESTAMP, arrival_time TIMESTAMP, 
        price FLOAT, departure_station VARCHAR(100), arrival_station VARCHAR(100)
 )
LANGUAGE plpgsql
AS $$
DECLARE
trans_id INT;

BEGIN
    INSERT INTO Transportation (arrival_time, departure_time, price, departure_point, arrival_point) VALUES 
            (arrival_time, departure_time, price, departure_station, arrival_station) returning transportation_id INTO trans_id;
    INSERT INTO Bus (bus_number, bus_company, transportation_id) VALUES
            (busNo, bus_company, trans_id);

END $$

drop PROCEDURE addBus;

CALL addBus('S2829', 'GoBus', '2023-08-03 04:00:00', '2023-08-03 12:00:00', 503.23, 'Rehab Gate 12', 'Dahab Station') ;

SELECT * FROM Bus;
SELECT * FROM Transportation;

DELETE FROM Transportation;


---------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE addTransportToPlan (type VARCHAR(20), number VARCHAR(20), plan_id INT)
LANGUAGE plpgsql
AS $$
DECLARE

trans_id INT;

BEGIN
    IF type = 'Flight' OR type = 'flight' THEN
        SELECT transportation_id INTO trans_id FROM Flight WHERE flight_number = number;
    ELSIF type = 'Train' THEN
        SELECT transportation_id INTO trans_id FROM Train WHERE train_number = number;
    ELSIF type = 'Bus' THEN
        SELECT transportation_id INTO trans_id FROM Bus WHERE bus_number = number;
    ELSE
        raise notice '% is NOT a valid transport type', type ; RETURN;
    END IF;

    IF trans_id IS NULL THEN 
        raise notice '% number % NOT Found!', type, number;
    ELSE
        INSERT INTO TransportationPlanTrips(plan_id, transportation_id) VALUES (plan_id, trans_id);
        raise notice '% number % added to your plan!', type, number;
    END IF;

END $$

-- drop PROCEDURE addTransportToPlan;

-- CALL addTransportToPlan('flight', 'MS736', 2) ;

-- SELECT * FROM transportationplantrips;
-- SELECT * FROM Transportation;

-- DELETE FROM TransportationPlanTrips;


---------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE addHotel (name VARCHAR(50), location VARCHAR(200), 
        price FLOAT, rating FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Hotel (name, location, price, rating) VALUES (name, location, price, rating);
END $$

-- drop PROCEDURE addHotel;

-- CALL addHotel('Renaissance Hotel', '142 Charles de Gaulle Rue, Paris, France', 25.0, 4.8);

-- SELECT * FROM Hotel;

-- DELETE FROM Hotel;


---------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE addHotelToTrip(trip_id INT, hotel_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Trip_Hotel VALUES (trip_id, hotel_id);
END $$

-- drop PROCEDURE addHotelToTrip;

CALL addHotelToTrip(9, 2);

SELECT * FROM trip_hotel;

DELETE FROM Trip_Hotel;

------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE addInterest(trip_id INT, interest VARCHAR(50))
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO TripInterests VALUES (trip_id, interest);
END $$

-- drop PROCEDURE addInterest;

-- CALL addInterest(9, 'Hiking');

-- SELECT * FROM tripinterests;

-- DELETE FROM TripInterests;

--------------------------------------------------------------------------------------------------------


CREATE OR REPLACE PROCEDURE addTripDestination(trip_id INT, city_from VARCHAR(50), country_from VARCHAR(50), 
    city_to VARCHAR(50), country_to VARCHAR(50), start_date DATE, end_date DATE)
LANGUAGE plpgsql
AS $$
DECLARE 
dest_id INT;
BEGIN
    SELECT destination_id INTO dest_id FROM Destination WHERE city = city_to AND country = country_to;
    INSERT INTO Trip_Destinations VALUES (trip_id, dest_id, city_from, country_from, start_date, end_date);
END $$

-- drop PROCEDURE addTripDestination;

-- CALL addTripDestination(9,'Paris', 'France', 'Barcelona', 'Spain', '2023-08-05', '2023-08-08');

-- SELECT * FROM trip_destinations;

-- DELETE FROM trip_destinations;

--------------------------------------------------------------------------------------------------------


CREATE OR REPLACE PROCEDURE addRestaurant (name VARCHAR(50), location VARCHAR(200), description VARCHAR(1000),
        avg_price FLOAT, rating FLOAT, opening_time TIME, closing_time TIME
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Restaurant (name, location, description, avg_price, rating, opening_time, closing_time) VALUES 
        (name, location, description, avg_price, rating, opening_time, closing_time);
END $$

-- drop PROCEDURE addRestaurant;

-- CALL addRestaurant('Five Guys', '142 Charles de Gaulle Rue, Paris, France', 'Fast Food Chain serving burgers and fries', 12.0, 3.8, '10:00:00','20:00:00');

-- SELECT * FROM Restaurant;

-- DELETE FROM Restaurant;


---------------------------------------------------------------------------------------------------


CREATE OR REPLACE PROCEDURE addDayRestaurant (tripID INT, date DATE, 
    rest_name VARCHAR(50), rest_location VARCHAR(100), meal VARCHAR(50), startTime TIME, endTime TIME 
)
LANGUAGE plpgsql
AS $$
DECLARE
rest_id INT;

BEGIN
    -- check that there is nth else scheduled during the same interval

    IF (NOT EXISTS
        (SELECT restaurant_id FROM Day_Restaurant WHERE (start_time <= startTime AND end_time >= startTime) OR (start_time <= endTime AND end_time >= endTime))
    AND NOT EXISTS
        (SELECT attraction_id FROM Day_Activities WHERE (start_time <= startTime AND end_time >= startTime) OR (start_time <= endTime AND end_time >= endTime))
    )
    THEN 
        SELECT restaurant_id INTO rest_id FROM Restaurant WHERE rest_name = name AND rest_location = location;
        -- raise notice '%', rest_id;
        INSERT INTO Day_Restaurant VALUES (rest_id, tripID, date, meal, startTime, endTime);
    END IF;
END $$

-- drop PROCEDURE addDayRestaurant;

-- CALL addDayRestaurant(2, '2023-08-03', 'Five Guys', '142 Charles de Gaulle Rue, Paris, France', 'Lunch', '14:00:00', '16:00:00' );

-- SELECT * FROM Day_Restaurant;

-- DELETE FROM Day_Restaurant;


---------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE addDayActivity (tripID INT, date DATE, 
    attr_name VARCHAR(50), attr_location VARCHAR(100), startTime TIME, endTime TIME
)
LANGUAGE plpgsql
AS $$
DECLARE
attr_id INT;
BEGIN
    -- check that there is nth else scheduled during the same interval
    IF (NOT EXISTS
        (SELECT restaurant_id FROM Day_Restaurant WHERE (start_time <= startTime AND end_time >= startTime) OR (start_time <= endTime AND end_time >= endTime))
    AND NOT EXISTS
        (SELECT attraction_id FROM Day_Activities WHERE (start_time <= startTime AND end_time >= startTime) OR (start_time <= endTime AND end_time >= endTime))
    )
    THEN 

        SELECT attraction_id INTO attr_id FROM Attraction WHERE attr_name = name AND attr_location = location;
        -- raise notice '%', rest_id;

        -- SELECT attraction_id INTO attr_id FROM DayActivity WHERE trip_id = trip_id

        INSERT INTO Day_Activities VALUES (tripID, date, attr_id, startTime, endTime);
    ELSE
        raise notice 'You already have sth else scheduled for that time';
    END IF;

END $$

-- drop PROCEDURE addDayActivity;

-- CALL addDayActivity(2, '2023-08-03', 'Disney Land', '142 Charles de Gaulle Rue, Paris, France', '14:00:00', '16:00:00');

-- SELECT * FROM day_activities;

-- DELETE FROM Day_Activities;


---------------------------------------------------------------------------------------------------


CREATE OR REPLACE PROCEDURE rateAttraction (userID INT, attrID INT, user_rating FLOAT)

LANGUAGE plpgsql
AS $$
DECLARE
--prev_rating FLOAT;
new_rating FLOAT;
BEGIN
    --SELECT rating INTO prev_rating FROM Attraction WHERE attrID = attraction_id;

    INSERT INTO Attraction_Rating VALUES (userID, attrID, user_rating);

    SELECT AVG(rating) INTO new_rating FROM Attraction_Rating WHERE attraction_id = attrID;
    -- raise notice '%', rest_id;

    -- SELECT attraction_id INTO attr_id FROM DayActivity WHERE trip_id = trip_id

    UPDATE Attraction
    SET rating = new_rating
    WHERE attraction_id = attrID;

END $$

-- drop PROCEDURE rateAttraction;

-- CALL rateAttraction(2,1, 3.4);

-- SELECT * FROM attraction_rating;

-- SELECT * FROM Users;
-- SELECT * FROM Attraction;

-- DELETE FROM attraction_rating;


---------------------------------------------------------------------------------------------------




CREATE OR REPLACE PROCEDURE rateRestaurant (userID INT, restID INT, user_rating FLOAT)

LANGUAGE plpgsql
AS $$
DECLARE
new_rating FLOAT;
BEGIN
    INSERT INTO Restaurant_Rating VALUES (userID, restID, user_rating);

    SELECT AVG(rating) INTO new_rating FROM restaurant_rating WHERE restaurant_id = restID;
    -- raise notice '%', rest_id;

    UPDATE Restaurant
    SET rating = new_rating
    WHERE restaurant_id = restID;

END $$

-- drop PROCEDURE rateRestaurant;

-- CALL rateRestaurant(1, 1, 4.3);

-- SELECT * FROM restaurant_rating;

-- SELECT * FROM Users;
-- SELECT * FROM Restaurant;

-- DELETE FROM restaurant_rating;


---------------------------------------------------------------------------------------------------




CREATE OR REPLACE PROCEDURE rateHotel (userID INT, hotelID INT, user_rating FLOAT)

LANGUAGE plpgsql
AS $$
DECLARE
new_rating FLOAT;
BEGIN
    INSERT INTO Hotel_Rating VALUES (userID, hotelID, user_rating);

    SELECT AVG(rating) INTO new_rating FROM Hotel_Rating WHERE hotel_id = hotelID;
    -- raise notice '%', rest_id;

    UPDATE Hotel
    SET rating = new_rating
    WHERE hotel_id = hotelID;

END $$

-- drop PROCEDURE rateHotel;

-- CALL rateHotel(2, 1, 3.6);

-- SELECT * FROM hotel_rating;

-- SELECT * FROM Users;
-- SELECT * FROM Hotel;

-- DELETE FROM hotel_rating;


---------------------------------------------------------------------------------------------------

