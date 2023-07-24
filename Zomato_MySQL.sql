create database zomato_project;
use zomato_project;

CREATE TABLE zomato (
   Datekey DATE PRIMARY KEY,
   RestaurantID INT,
   CountryCode INT PRIMARY KEY,
   City VARCHAR(20),
   Adress VARCHAR(150),
   Locality VARCHAR(20),
   LocalityVerbose VARCHAR(20),
   Longitude INT,
   Latitude INT,
   Cuisines VARCHAR(20),
   Currency VARCHAR(20),
   Has_Table_booking VARCHAR(10),
   Has_Online_delivery VARCHAR(10),
   Is_delivering_now VARCHAR(10),
   Switch_to_order_menu VARCHAR(10),
   Price_range INT,
   Votes INT,
   Average_Cost_for_two INT,
   Rating INT,
   Datekey_Opening VARCHAR(20),
   Datekey Date) ;
   
describe table zomata;
   
select count(*) from zomato;
select count(datekey_opening) from zomata;
alter table countrycode change column `ï»¿Country Code` Country_code int  ;
alter table zomato change column `ï»¿RestaurantID` RestaurantID int  ;
RENAME TABLE `country-code` TO `countrycode`;

describe countrycode;
alter table countrycode add constraint PK_countrycode primary key(Country_code);
alter table zomato add	foreign key (countrycode) references countrycode(Country_code); 



CREATE TABLE CalendarTable (
   Datekey DATE PRIMARY KEY,
   Year INT,
   Monthno INT,
   Monthfullname VARCHAR(20),
   Quarter VARCHAR(2),
   YearMonth VARCHAR(7),
   Weekdayno INT,
   Weekdayname VARCHAR(20),
   FinancialMonth VARCHAR(4),
   FinancialQuarter VARCHAR(4));
   
describe calendartable;
alter table calendartable add constraint PK_calendartable primary key(datekey);
alter table zomato add	foreign key (`Datekey`) references calendartable(Datekey); 


INSERT INTO CalendarTable (Datekey, Year, Monthno, Monthfullname, Quarter, YearMonth, Weekdayno, Weekdayname, FinancialMonth, FinancialQuarter)
SELECT
   Datekey,
   YEAR(Datekey) AS Year,
   MONTH(Datekey) AS Month,
   monthname(datekey) AS Month_Name,
   CONCAT('Q', CEILING(MONTH(Datekey)/3.0)) AS Quarter,
   CONCAT(YEAR(Datekey), '-', LEFT(MONTH(Datekey), 3)) AS YearMonth,
   dayofweek(datekey) AS Weekdayno,
   dayname(datekey) AS Weekdayname,
   CASE WHEN MONTH(Datekey) BETWEEN 4 AND 12 THEN CONCAT('FM', MONTH(Datekey) - 3) ELSE CONCAT('FM', MONTH(Datekey) + 9) END AS FinancialMonth,
   CONCAT('FQ', CEILING((CASE WHEN MONTH(Datekey) BETWEEN 4 AND 12 THEN MONTH(Datekey) - 3 ELSE MONTH(Datekey) + 9 END)/3.0)) AS FinancialQuarter
FROM 
   zomato
GROUP BY Datekey;

-- 3 Find the Numbers of Restaurants based on City and Country.
SELECT Country, City, COUNT(*) AS NumberOfRestaurants
FROM zomato
join countrycode
on Country_Code = CountryCode
GROUP BY  country,City;

-- 4 Numbers of Restaurants opening based on Year, Quarter, Month
SELECT
   YEAR(Datekey) AS Year,
   CONCAT('Q', CEILING(MONTH(Datekey)/3.0)) AS Quarter,
   monthname(datekey) AS Month,
   COUNT(*) AS NumberOfRestaurants
FROM zomato
GROUP BY YEAR(Datekey), CONCAT('Q', CEILING(MONTH(Datekey)/3.0)), monthname(datekey)
order by year;

-- 5 Count of Restaurants based on Average Ratings
SELECT
   AVG(Rating) AS AverageRating,
   COUNT(*) AS NumberOfRestaurants
FROM zomato
GROUP BY Rating
OrDER BY rating;

-- 6 Create buckets based on Average Price of reasonable size and find out how many restaurants fall in each bucket

SELECT 
  CASE 
    WHEN res_avg < 500 THEN 'Low' 
    WHEN res_avg BETWEEN 500 AND 1000 THEN 'Medium-Low'
    WHEN res_avg BETWEEN 1000 AND 2000 THEN 'Medium-High'
    ELSE 'High'
  END AS Price_Range,
  COUNT(*) AS Num_Restaurants,
  CONVERT(res_avg * 0.014, DECIMAL(10, 2)) AS Price_USD
FROM (
  SELECT 
    RestaurantID,
    AVG(Average_Cost_for_two) AS res_avg
  FROM zomato
  GROUP BY RestaurantID
) AS avg_prices
GROUP BY Price_Range;

-- 7 Percentage of Restaurants based on "Has_Table_booking"
SELECT 
  Has_Table_booking,
  CONCAT(ROUND(COUNT(*) / (SELECT COUNT(*) FROM zomato) * 100, 2), '%') AS Percent
FROM zomato
GROUP BY Has_Table_booking;


-- 8 Percentage of Restaurants based on "Has_Online_delivery"
SELECT
   Has_Online_delivery,
   COUNT(*) AS NumberOfRestaurants,
   CONCAT(ROUND(COUNT(*)/(SELECT COUNT(*) FROM zomato) * 100, 2), '%') AS PercentageOfRestaurants
FROM zomato
GROUP BY Has_Online_delivery;

-- 9  Develop Charts based on Cuisines, City, Ratings
SELECT Cuisines, COUNT(*) AS NumberOfRestaurants
FROM zomato
GROUP BY Cuisines
ORDER BY COUNT(*) DESC
limit 10;

SELECT City, COUNT(*) AS NumberOfRestaurants
FROM zomato
GROUP BY City
ORDER BY COUNT(*) DESC
limit 10;


SELECT 
    CAST(Rating AS SIGNED) AS Rating,
    COUNT(*) AS NumberOfRestaurants
FROM zomato
GROUP BY CAST(Rating AS SIGNED)
ORDER BY CAST(Rating AS SIGNED);


