/*
------------------------
--CASE STUDY QUESTIONS for Data Cleaning & Transformation--
------------------------ 
*/

/*Looking at the customer_orders table below, we can see that there are

In the exclusions column, there are missing/ blank spaces ' ' and null values.
In the extras column, there are missing/ blank spaces ' ' and null values.*/

/*
Our course of action to clean the table:

Create a temporary table with all the columns
Remove null values in exlusions and extras columns and replace with blank space ' '/0.
*/

CREATE TEMPORARY TABLE customer_order_temp
SELECT 
    order_id,
    customer_id,
    pizza_id,
    CASE
        WHEN exclusions IS null or exclusions LIKE 'null'  or exclusions = ' ' or exclusions = 0 THEN 0
        ELSE exclusions
        END AS exclusions,
	CASE
       WHEN extras IS null or extras LIKE 'null' or extras = 0 THEN 0
        ELSE extras
        END AS extras,
	order_time
FROM pizza_runner.customer_orders;


# 	Cleaning runner_orders
/*Looking at the runner_orders table below, we can see that there are

In the exclusions column, there are missing/ blank spaces ' ' and null values.
In the extras column, there are missing/ blank spaces ' ' and null values*/


CREATE TEMPORARY TABLE runner_orders_temp AS
SELECT 
  order_id, 
  runner_id,  
  CASE
	  WHEN pickup_time LIKE 'null' THEN ' '
	  ELSE pickup_time
	  END AS pickup_time,
  CASE
	  WHEN distance LIKE 'null' THEN ' '
	  WHEN distance LIKE '%km' THEN TRIM('km' from distance)
	  ELSE distance 
    END AS distance,
  CASE
	  WHEN duration LIKE 'null' THEN ' '
	  WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
	  WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	  WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
	  ELSE duration
	  END AS duration,
  CASE
	  WHEN cancellation IS NULL or cancellation LIKE 'null' THEN ' '
	  ELSE cancellation
	  END AS cancellation
FROM pizza_runner.runner_orders;

# we alter the pickup_time, distance and duration columns to the correct data type.
ALTER TABLE runner_orders_temp
ALTER COLUMN pickup_time DATE,
ALTER COLUMN distance FLOAT,
ALTER COLUMN duration INT;














