--Overview of the data
SELECT*
FROM projects.default.bright_motors
LIMIT 100;


----------------------------------------
--CHECK COLUMN DATA TYPES
--year	bigint
--make	string
--model	string
--trim	string
--body	string
--transmission	string
--vin	string
--state	string
--condition	bigint
--odometer	bigint
--color	string
--interior	string
--seller	string
--mmr	bigint
--sellingprice	bigint
--saledate	string
----------------------------------------
DESCRIBE TABLE projects.default.bright_motors;


----------------------------------------
--Car makes
--97 makes
----------------------------------------
SELECT DISTINCT make
FROM projects.default.bright_motors;


----------------------------------------
--Car models
--974 models
----------------------------------------
SELECT DISTINCT model
FROM projects.default.bright_motors;


----------------------------------------
--dealerships
--14261 sellers
----------------------------------------
SELECT DISTINCT seller
FROM projects.default.bright_motors;



----------------------------------------
--trim
--1963 
----------------------------------------
SELECT DISTINCT trim
FROM projects.default.bright_motors;



----------------------------------------
--body
--87
----------------------------------------
SELECT DISTINCT body
FROM projects.default.bright_motors;


----------------------------------------
--state
--38 states
----------------------------------------
SELECT DISTINCT state
FROM projects.default.bright_motors;


----------------------------------------
--Interior
--18
----------------------------------------
SELECT DISTINCT interior
FROM projects.default.bright_motors;


----------------------------------------
--Checking for null values
--make,model,trim,body,transmission, condition, snmr, ellingprice and sale date have null have null values
----------------------------------------
SELECT*
FROM projects.default.bright_motors
WHERE saledate IS NULL;







----------------------------------------
--Main code
----------------------------------------

--Change the year column to integer
SELECT CAST(year AS INT) AS year,

--Extracting dates
date_format((to_timestamp(regexp_replace(saledate, '^[A-Za-z]{3} ', ''), 'MMM dd yyyy HH:mm:ss')), 'yyyy/MM/dd') AS selling_date,
Monthname(to_timestamp(regexp_replace(saledate, '^[A-Za-z]{3} ', ''), 'MMM dd yyyy HH:mm:ss')) AS Month_name,
Dayofmonth(to_timestamp(regexp_replace(saledate, '^[A-Za-z]{3} ', ''), 'MMM dd yyyy HH:mm:ss')) AS day_of_month,
Dayname(to_timestamp(regexp_replace(saledate, '^[A-Za-z]{3} ', ''), 'MMM dd yyyy HH:mm:ss')) AS day_name,
date_format(to_timestamp(regexp_replace(saledate, '^[A-Za-z]{3} ', ''), 'MMM dd yyyy HH:mm:ss'), 'HH:mm') AS time_of_sale,

--Number of vehicles
COUNT(DISTINCT vin) AS number_of_vehicles,

--dealing with null values using COALESCE
COALESCE(make,'Not provided') AS make,
COALESCE(model,'Not provided') AS model,
COALESCE(body,'Not provided') AS body,
COALESCE(body,'Not provided') AS body,
COALESCE(transmission,'Not provided') AS transmission,
COALESCE(state,'Not provided') AS state,
COALESCE(seller,'Not provided') AS seller,
COALESCE(condition, (SELECT ROUND(AVG(condition),0) FROM projects.default.bright_motors)) AS condition,
COALESCE(odometer,(SELECT ROUND(AVG(odometer),0) FROM projects.default.bright_motors)) AS odometer,
COALESCE(mmr, (SELECT ROUND(AVG(mmr),0) FROM projects.default.bright_motors)) AS mmr,
COALESCE(sellingprice, (SELECT ROUND(AVG(sellingprice),0) FROM projects.default.bright_motors)) AS sellingprice,

--dealing with null values using CASE
CASE
    WHEN interior IS NULL THEN 'Not provided'
    WHEN interior='â€”' THEN 'Not provided'
    WHEN interior='—' THEN 'Not provided'
    ELSE interior
END AS interior,

CASE
    WHEN color IS NULL THEN 'Not provided'
    WHEN color='â€”' THEN 'Not provided'
    WHEN color='—' THEN 'Not provided'
    ELSE color
END AS color,

--time buckets
CASE
    WHEN  date_format(to_timestamp(regexp_replace(saledate, '^[A-Za-z]{3} ', ''), 'MMM dd yyyy HH:mm:ss'), 'HH:mm') BETWEEN '06:00' AND '11:59' THEN 'morning'
    WHEN date_format(to_timestamp(regexp_replace(saledate, '^[A-Za-z]{3} ', ''), 'MMM dd yyyy HH:mm:ss'), 'HH:mm') BETWEEN '12:00' AND '17:59' THEN 'afternoon'
    WHEN date_format(to_timestamp(regexp_replace(saledate, '^[A-Za-z]{3} ', ''), 'MMM dd yyyy HH:mm:ss'), 'HH:mm') BETWEEN '18:00' AND '23:59' THEN 'night'
    WHEN date_format(to_timestamp(regexp_replace(saledate, '^[A-Za-z]{3} ', ''), 'MMM dd yyyy HH:mm:ss'), 'HH:mm') BETWEEN '00:00' AND '05:59' THEN 'early morning'
END AS time_buckets,

--Price buckets
CASE
    WHEN  sellingprice BETWEEN 1 AND 9999 THEN 'cheap'
    WHEN  sellingprice BETWEEN 10000 AND 29999 THEN 'affordable'
    WHEN  sellingprice BETWEEN 30000 AND 69999 THEN 'Expensive'
    WHEN  sellingprice >70000 THEN 'Very expensive'
END AS customer_segment,

--Mileage
CASE
    WHEN  sellingprice BETWEEN 1 AND 29999 THEN 'low'
    WHEN  sellingprice BETWEEN 30000 AND 99999 THEN 'Moderate'
    WHEN  sellingprice BETWEEN 100000 AND 499999 THEN 'High'
    WHEN  sellingprice >500000 THEN 'Very high'
END AS mileage,

CASE
    WHEN  ROUND((sellingprice-mmr)/sellingprice*100,0)<=5 THEN 'low'
    WHEN  ROUND((sellingprice-mmr)/sellingprice*100,0) BETWEEN 5 AND 10 THEN 'Medium'
    WHEN  ROUND((sellingprice-mmr)/sellingprice*100,0)>10 THEN 'High'
END AS performance_tiers

FROM projects.default.bright_motors
GROUP BY 
make, model, body, transmission, state,condition,  color, odometer, seller, mmr,sellingprice,
CAST(year AS INT),
date_format((to_timestamp(regexp_replace(saledate, '^[A-Za-z]{3} ', ''), 'MMM dd yyyy HH:mm:ss')), 'yyyy/MM/dd'),
Monthname(to_timestamp(regexp_replace(saledate, '^[A-Za-z]{3} ', ''), 'MMM dd yyyy HH:mm:ss')),
Dayofmonth(to_timestamp(regexp_replace(saledate, '^[A-Za-z]{3} ', ''), 'MMM dd yyyy HH:mm:ss')),
Dayname(to_timestamp(regexp_replace(saledate, '^[A-Za-z]{3} ', ''), 'MMM dd yyyy HH:mm:ss')),
date_format(to_timestamp(regexp_replace(saledate, '^[A-Za-z]{3} ', ''), 'MMM dd yyyy HH:mm:ss'), 'HH:mm'),
CASE
    WHEN interior IS NULL THEN 'Not provided'
     WHEN interior='â€”' THEN 'Not provided'
     WHEN interior='—' THEN 'Not provided'
    ELSE interior
END,
CASE
    WHEN  date_format(to_timestamp(regexp_replace(saledate, '^[A-Za-z]{3} ', ''), 'MMM dd yyyy HH:mm:ss'), 'HH:mm') BETWEEN '06:00' AND '11:59' THEN 'morning'
    WHEN date_format(to_timestamp(regexp_replace(saledate, '^[A-Za-z]{3} ', ''), 'MMM dd yyyy HH:mm:ss'), 'HH:mm') BETWEEN '12:00' AND '17:59' THEN 'afternoon'
    WHEN date_format(to_timestamp(regexp_replace(saledate, '^[A-Za-z]{3} ', ''), 'MMM dd yyyy HH:mm:ss'), 'HH:mm') BETWEEN '18:00' AND '23:59' THEN 'night'
    WHEN date_format(to_timestamp(regexp_replace(saledate, '^[A-Za-z]{3} ', ''), 'MMM dd yyyy HH:mm:ss'), 'HH:mm') BETWEEN '00:00' AND '05:59' THEN 'early morning'
END,
CASE
    WHEN  sellingprice BETWEEN 1 AND 9999 THEN 'cheap'
    WHEN  sellingprice BETWEEN 10000 AND 29999 THEN 'affordable'
    WHEN  sellingprice BETWEEN 30000 AND 69999 THEN 'Expensive'
    WHEN  sellingprice >70000 THEN 'Very expensive'
END,
CASE
    WHEN  sellingprice BETWEEN 1 AND 29999 THEN 'low'
    WHEN  sellingprice BETWEEN 30000 AND 99999 THEN 'Moderate'
    WHEN  sellingprice BETWEEN 100000 AND 499999 THEN 'High'
    WHEN  sellingprice >500000 THEN 'Very high'
END,
CASE
    WHEN  ROUND((sellingprice-mmr)/sellingprice*100,0)<=5 THEN 'low'
    WHEN  ROUND((sellingprice-mmr)/sellingprice*100,0) BETWEEN 5 AND 10 THEN 'Medium'
    WHEN  ROUND((sellingprice-mmr)/sellingprice*100,0)>10 THEN 'High'
END 
