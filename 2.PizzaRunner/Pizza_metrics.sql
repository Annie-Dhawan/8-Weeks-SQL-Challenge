  /*
------------------------
--CASE STUDY QUESTIONS for Pizza Metrics--
------------------------ 
*/
USE pizza_runner;

#1. How many pizzas were ordered?
SELECT COUNT(*) AS pizza_order_count FROM customer_orders;


#2. How many unique customer orders were made?
SELECT COUNT(DISTINCT(order_id)) AS unique_order_count from customer_orders;


#3. How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS successful_orders
FROM runner_orders
WHERE distance!=0
GROUP BY runner_id;

#4. How many of each type of pizza was delivered?
SELECT  c.pizza_id,pn.pizza_name, COUNT(*) AS total_pizza_id
FROM customer_orders AS c
JOIN runner_orders ro on c.order_id = ro.order_id
JOIN pizza_names pn ON c.pizza_id = pn.pizza_id
WHERE distance != 0
GROUP BY c.pizza_id,pn.pizza_name;

#5. How many Vegetarian and Meatlovers were ordered by each customer?**
SELECT c.customer_id, pn.pizza_name, COUNT(*) AS total
FROM customer_orders AS c
JOIN pizza_names pn ON c.pizza_id = pn.pizza_id
JOIN runner_orders ro on c.order_id = ro.order_id
WHERE distance != 0 
GROUP BY c.customer_id, pn.pizza_name
ORDER BY c.customer_id;

#6. What was the maximum number of pizzas delivered in a single order?
SELECT c.order_id ,COUNT(*) AS total_pizza_per_order
FROM customer_orders c JOIN
Runner_orders ro on c.order_id = ro.order_id
WHERE distance != 0 
GROUP BY c.order_id,c.order_id;

#7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
  c.customer_id,
  SUM(
    CASE WHEN c.exclusions <> 0 OR c.extras <> 0 THEN 1
    ELSE 0
    END) AS at_least_1_change,
  SUM(
    CASE WHEN c.exclusions = 0 AND c.extras = 0 THEN 1 
    ELSE 0
    END) AS no_change
FROM customer_orders AS c
JOIN runner_orders AS r
  ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.customer_id
ORDER BY c.customer_id;

#8. How many pizzas were delivered that had both exclusions and extras?
SELECT 
  SUM(
    CASE WHEN c.exclusions <> 0 OR c.extras <> 0 THEN 1
    ELSE 0
    END) AS exclusion_extras_change
FROM customer_orders AS c
JOIN runner_orders AS r
  ON c.order_id = r.order_id
WHERE r.distance != 0
      AND exclusions <> 0 
      AND extras <> 0;
      
#9. What was the total volume of pizzas ordered for each hour of the day?
SELECT HOUR(order_time) AS hours, COUNT(order_id) AS pizza_count
FROM customer_orders
GROUP BY HOUR(order_time);

#10. What was the volume of orders for each day of the week?
SELECT WEEKDAY(order_time) AS hours, COUNT(order_id) AS pizza_count
FROM customer_orders
GROUP BY WEEKDAY(order_time);

#Note: 0 = Monday, 1 = Tuesday, 2 = Wednesday, 3 = Thursday, 4 = Friday, 5 = Saturday, 6 = Sunday.