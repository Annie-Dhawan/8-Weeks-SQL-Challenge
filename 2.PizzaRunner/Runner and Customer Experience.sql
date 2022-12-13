  /*
------------------------
--CASE STUDY QUESTIONS for B. Runner and Customer Experience--
------------------------ 
*/

#1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT runner_id, WEEK(registration_date) AS weeks  
FROM runners;

#2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
CREATE TEMPORARY TABLE time_taken_cte 
SELECT r.runner_id, c.order_id,c.order_time,r.pickup_time,	
timestampdiff(MINUTE, c.order_time, r.pickup_time) AS pickup_minutes
FROM 
customer_orders c JOIN
runner_orders r ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.order_id, c.order_time, r.pickup_time,r.runner_id;

SELECT 
  AVG(pickup_minutes) AS avg_pickup_minutes
FROM time_taken_cte
WHERE pickup_minutes > 1;

#We can also do it runner wise. To know the avg time of each runner to pickup the order

#3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
CREATE TEMPORARY TABLE prep_time_cte AS
  SELECT 
    c.order_id, 
    COUNT(c.order_id) AS pizza_order, 
    c.order_time, 
    r.pickup_time, 
    timestampdiff(MINUTE, c.order_time, r.pickup_time) AS prep_time_minutes
  FROM customer_orders AS c
  JOIN runner_orders AS r
    ON c.order_id = r.order_id
  WHERE r.distance != 0
  GROUP BY c.order_id, c.order_time, r.pickup_time;


SELECT 
  pizza_order, 
  AVG(prep_time_minutes) AS avg_prep_time_minutes
FROM prep_time_cte
WHERE prep_time_minutes > 1
GROUP BY pizza_order;

#4. What was the average distance travelled for each customer?
SELECT c.customer_id, ROUND(AVG(r.distance),2) AS avg_dist FROM
customer_orders c JOIN
runner_orders r ON c.order_id = r.order_id
WHERE r.duration != 0
GROUP BY c.customer_id;

#(Assuming that distance is calculated from Pizza Runner HQ to customer’s place)
#Customer 104 stays the nearest to Pizza Runner HQ at average distance of 10km, whereas Customer 105 stays the furthest at 25km.


#5. What was the difference between the longest and shortest delivery times for all orders?
#the duration col is in the form of varchar
CREATE TEMPORARY TABLE runner_order2 
SELECT order_id, REGEXP_SUBSTR(duration,"[0-9]+") as duration
FROM runner_orders
WHERE duration != 0;

SELECT MAX(duration) - MIN(duration) AS delivery_time_difference
FROM runner_orders2
where duration !=0;

#7. What is the successful delivery percentage for each runner?
SELECT 
  runner_id, 
  ROUND(100 * SUM(
    CASE WHEN distance = 0 THEN 0
    ELSE 1 END) / COUNT(*), 0) AS success_perc
FROM runner_orders
GROUP BY runner_id;

/* Runner 1 has 100% successful delivery.
Runner 2 has 75% successful delivery.
Runner 3 has 50% successful delivery
(It’s not right to attribute successful delivery to runners as order cancellations are out of the runner’s control.) */







