-- For pset7 https://cs50.harvard.edu/x/2022/psets/7/fiftyville/
-- Log of all SQL commands used to solve the problem based on a crime mystery of a stolen duck in the ficitonal Fiftyville


-- Keep a log of any SQL queries you execute as you solve the mystery.
-- First check the schema of the tables in the database
.schema

-- crime_scene_reports will be useful to check for the crime on Humphrey Street on July 28, 2021
select description FROM crime_scene_reports WHERE year = 2021 AND month = 7 AND day = 28 AND street = "Humphrey Street";
-- The first result from the query is relevent to the task:
-- Theft of the CS50 duck took place at 10:15am at the Humphrey Street bakery. Interviews were conducted today with three witnesses who were present at the time – each of their interview transcripts mentions the bakery.

-- Need to check interviews of the three witnessess at July 28, 2021 with the transcript containing 'bakery'
select name, transcript FROM interviews WHERE year = 2021 AND month = 7 AND day = 28 AND transcript LIKE "%bakery%";
-- Outputs 4 results:
-- | Ruth    | Sometime within ten minutes of the theft, I saw the thief get into a car in the bakery parking lot and drive away. If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot in that time frame.
-- | Eugene  | I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at Emma's bakery, I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money.
-- | Raymond | As the thief was leaving the bakery, they called someone who talked to them for less than a minute. In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow. The thief then asked the person on the other end of the phone to purchase the flight ticket. |
-- | Emma    | I'm the bakery owner, and someone came in, suspiciously whispering into a phone for about half an hour. They never bought anything.
-- 4 leads:
--    Car leaving parking lot within 10 minutes after the crime.
--    ATM withdrawel some time before 10:15am on the day on Leggett Street
--    Phone call for <1 minute after 10:15am. planning to take earliest flight out on July 29, 2021.
--        The other person on the phone bought the plane ticket
--    Phone call for ~30 minutes. Time unknown

-- 1st lead:
select hour, minute, activity, license_plate FROM bakery_security_logs WHERE year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute BETWEEN 15 AND 25 AND activity = "exit";
-- Output contains 8 licence plates exiting between 10:16 and 10:23 am

-- Instead of checking each lead, trying to combine multiple leads to narrow down the data
SELECT *
FROM people
JOIN bank_accounts ON person_id = people.id
JOIN atm_transactions ON atm_transactions.account_number = bank_accounts.account_number
JOIN bakery_security_logs ON bakery_security_logs.license_plate = people.license_plate
WHERE atm_transactions.year = 2021 AND atm_transactions.month = 7 AND atm_transactions.day = 28;

-- Using JOIN x AS y to help with readability. Filter ATM by streat to improve filter.
SELECT *
FROM people
JOIN bank_accounts AS ba ON person_id = people.id
JOIN atm_transactions AS atm ON atm.account_number = ba.account_number
JOIN bakery_security_logs ON bakery_security_logs.license_plate = people.license_plate
WHERE atm.year = 2021 AND atm.month = 7 AND atm.day = 28 AND atm_location = "Leggett Street";

-- Trying even more filters
SELECT *
FROM people
JOIN bank_accounts AS bank ON person_id = people.id
JOIN atm_transactions AS atm ON atm.account_number = bank.account_number
JOIN phone_calls AS phone ON phone.caller = people.name
JOIN bakery_security_logs AS sec ON sec.license_plate = people.license_plate
-- ATM transactions  on July 28, 2021 on Leggett Street
WHERE atm.year = 2021
AND atm.month = 7
AND atm.day = 28
AND atm_location = "Leggett Street"
-- Cars exiting on July 28, 2021 between 10:15am and 10:25am
AND sec.year = 2021
AND sec.month = 7
AND sec.day = 28
AND sec.hour = 10
AND sec.minute BETWEEN 15 AND 25
AND sec.activity = "exit"
-- -- Phone call on July 28, 2021 after 10:15am with duration <1min
AND phone.year = 2021
AND phone.month = 7
AND phone.day = 28
AND phone.duration < 60;
-- Output is blank so will debug by testing each part

-- Testing first part of filter but including all the joins
SELECT *
FROM people
JOIN bank_accounts AS bank ON person_id = people.id
JOIN atm_transactions AS atm ON atm.account_number = bank.account_number
JOIN phone_calls AS phone ON phone.caller = people.name
JOIN bakery_security_logs AS sec ON sec.license_plate = people.license_plate
-- ATM transactions  on July 28, 2021 on Leggett Street
WHERE atm.year = 2021
AND atm.month = 7
AND atm.day = 28
AND atm_location = "Leggett Street";
-- Output is blank

-- set JOIN ON phone.caller = people.phone_number rather than people.name
SELECT *
FROM people
JOIN bank_accounts AS bank ON person_id = people.id
JOIN atm_transactions AS atm ON atm.account_number = bank.account_number
JOIN phone_calls AS phone ON phone.caller = people.phone_number
JOIN bakery_security_logs AS sec ON sec.license_plate = people.license_plate
-- ATM transactions  on July 28, 2021 on Leggett Street
WHERE atm.year = 2021
AND atm.month = 7
AND atm.day = 28
AND atm_location = "Leggett Street"
-- Cars exiting on July 28, 2021 between 10:15am and 10:25am
AND sec.year = 2021
AND sec.month = 7
AND sec.day = 28
AND sec.hour = 10
AND sec.minute BETWEEN 15 AND 25
AND sec.activity = "exit";
-- Output is fixed. Includes 4 suspect names

-- Add filter by phone call lead
SELECT *
FROM people
JOIN bank_accounts AS bank ON person_id = people.id
JOIN atm_transactions AS atm ON atm.account_number = bank.account_number
JOIN phone_calls AS phone ON phone.caller = people.phone_number
JOIN bakery_security_logs AS sec ON sec.license_plate = people.license_plate
-- ATM transactions  on July 28, 2021 on Leggett Street
WHERE atm.year = 2021
AND atm.month = 7
AND atm.day = 28
AND atm_location = "Leggett Street"
-- Cars exiting on July 28, 2021 between 10:15am and 10:25am
AND sec.year = 2021
AND sec.month = 7
AND sec.day = 28
AND sec.hour = 10
AND sec.minute BETWEEN 15 AND 25
AND sec.activity = "exit"
-- -- Phone call on July 28, 2021 after 10:15am with duration <1min
AND phone.year = 2021
AND phone.month = 7
AND phone.day = 28
AND phone.duration < 60;
-- Output is now only 2 suspects

-- Next filter will be accoarding to the lead: planning to take earliest flight out on July 29, 2021
-- checking names of airports
SELECT *
FROM airports;
-- Need to filter by outgoing airport as "Fiftyville"

-- Add airport filter on 29 July from fiftyville
SELECT *
FROM people
JOIN bank_accounts AS bank ON person_id = people.id
JOIN atm_transactions AS atm ON atm.account_number = bank.account_number
JOIN phone_calls AS phone ON phone.caller = people.phone_number
JOIN bakery_security_logs AS sec ON sec.license_plate = people.license_plate
JOIN passengers ON passengers.passport_number = people.passport_number
JOIN flights ON flights.id = passengers.flight_id
JOIN airports ON airports.id = flights.origin_airport_id
-- ATM transactions  on July 28, 2021 on Leggett Street
WHERE atm.year = 2021
AND atm.month = 7
AND atm.day = 28
AND atm_location = "Leggett Street"
-- Cars exiting on July 28, 2021 between 10:15am and 10:25am
AND sec.year = 2021
AND sec.month = 7
AND sec.day = 28
AND sec.hour = 10
AND sec.minute BETWEEN 15 AND 25
AND sec.activity = "exit"
-- Phone call on July 28, 2021 after 10:15am with duration <1min
AND phone.year = 2021
AND phone.month = 7
AND phone.day = 28
AND phone.duration < 60
-- Filter by flights out of Fiftyville on July 29, 2021
AND city LIKE "%Fiftyville%"
AND flights.year = 2021
AND flights.month = 7
AND flights.day = 29;
-- Output contains 2 suspects

-- Add filter by earliest flight
SELECT *
FROM people
JOIN bank_accounts AS bank ON person_id = people.id
JOIN atm_transactions AS atm ON atm.account_number = bank.account_number
JOIN phone_calls AS phone ON phone.caller = people.phone_number
JOIN bakery_security_logs AS sec ON sec.license_plate = people.license_plate
JOIN passengers ON passengers.passport_number = people.passport_number
JOIN flights ON flights.id = passengers.flight_id
JOIN airports ON airports.id = flights.origin_airport_id
-- ATM transactions  on July 28, 2021 on Leggett Street
WHERE atm.year = 2021
AND atm.month = 7
AND atm.day = 28
AND atm_location = "Leggett Street"
-- Cars exiting on July 28, 2021 between 10:15am and 10:25am
AND sec.year = 2021
AND sec.month = 7
AND sec.day = 28
AND sec.hour = 10
AND sec.minute BETWEEN 15 AND 25
AND sec.activity = "exit"
-- Phone call on July 28, 2021 after 10:15am with duration <1min
AND phone.year = 2021
AND phone.month = 7
AND phone.day = 28
AND phone.duration < 60
-- Filter by flights out of Fiftyville on July 29, 2021
AND city LIKE "%Fiftyville%"
AND flights.year = 2021
AND flights.month = 7
AND flights.day = 29
-- Sort flights by departure time and select only first result
ORDER BY flights.hour, flights.minute
LIMIT 1;
-- Outputs only 1 suspect

-- Only ouput suspect name and destination city
SELECT name, destinations.city
FROM people
JOIN bank_accounts AS bank ON person_id = people.id
JOIN atm_transactions AS atm ON atm.account_number = bank.account_number
JOIN phone_calls AS phone ON phone.caller = people.phone_number
JOIN bakery_security_logs AS sec ON sec.license_plate = people.license_plate
JOIN passengers ON passengers.passport_number = people.passport_number
JOIN flights ON flights.id = passengers.flight_id
JOIN airports AS origins ON origins.id = flights.origin_airport_id
JOIN airports AS destinations ON destinations.id = flights.destination_airport_id
-- ATM transactions  on July 28, 2021 on Leggett Street
WHERE atm.year = 2021
AND atm.month = 7
AND atm.day = 28
AND atm_location = "Leggett Street"
-- Cars exiting on July 28, 2021 between 10:15am and 10:25am
AND sec.year = 2021
AND sec.month = 7
AND sec.day = 28
AND sec.hour = 10
AND sec.minute BETWEEN 15 AND 25
AND sec.activity = "exit"
-- Phone call on July 28, 2021 after 10:15am with duration <1min
AND phone.year = 2021
AND phone.month = 7
AND phone.day = 28
AND phone.duration < 60
-- Filter by flights out of Fiftyville on July 29, 2021
AND origins.city LIKE "%Fiftyville%"
AND flights.year = 2021
AND flights.month = 7
AND flights.day = 29
-- Sort flights by departure time and select only first result
ORDER BY flights.hour, flights.minute
LIMIT 1;

-- Join people table again to find accomplice name and add it to the output
SELECT thief.name, destinations.city, accomplice.name
FROM people AS thief
JOIN bank_accounts AS bank ON person_id = thief.id
JOIN atm_transactions AS atm ON atm.account_number = bank.account_number
JOIN phone_calls AS phone ON phone.caller = thief.phone_number
JOIN bakery_security_logs AS sec ON sec.license_plate = thief.license_plate
JOIN passengers ON passengers.passport_number = thief.passport_number
JOIN flights ON flights.id = passengers.flight_id
JOIN airports AS origins ON origins.id = flights.origin_airport_id
JOIN airports AS destinations ON destinations.id = flights.destination_airport_id
JOIN people AS accomplice ON accomplice.phone_number = phone.receiver
-- ATM transactions  on July 28, 2021 on Leggett Street
WHERE atm.year = 2021
AND atm.month = 7
AND atm.day = 28
AND atm_location = "Leggett Street"
-- Cars exiting on July 28, 2021 between 10:15am and 10:25am
AND sec.year = 2021
AND sec.month = 7
AND sec.day = 28
AND sec.hour = 10
AND sec.minute BETWEEN 15 AND 25
AND sec.activity = "exit"
-- Phone call on July 28, 2021 after 10:15am with duration <1min
AND phone.year = 2021
AND phone.month = 7
AND phone.day = 28
AND phone.duration < 60
-- Filter by flights out of Fiftyville on July 29, 2021
AND origins.city LIKE "%Fiftyville%"
AND flights.year = 2021
AND flights.month = 7
AND flights.day = 29
-- Sort flights by departure time and select only first result
ORDER BY flights.hour, flights.minute
LIMIT 1

-- Outputs the thief name, destination city and accomplice name:
    -- +-------+---------------+-------+
    -- | name  |     city      | name  |
    -- +-------+---------------+-------+
    -- | Bruce | New York City | Robin |
    -- +-------+---------------+-------+
