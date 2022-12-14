  /*
------------------------
--CASE STUDY QUESTIONS for  B. Data Analysis Questions--
------------------------ 
*/

#1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT(customer_id)) AS total_customers
FROM subscriptions;

#There are about 1,000 total customers Foodie-Fi ever had.

#2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
#The Q is asking us the number of users who are on trial monthly.
SELECT MONTH(s.start_date), MONTHNAME(s.start_date) AS month_name,# Cast to month in month's name
COUNT(*) AS trial_subscriptions
FROM subscriptions s
WHERE s.plan_id = 0
GROUP BY MONTHNAME(s.start_date),MONTH(s.start_date)
ORDER BY MONTH(s.start_date);

#March has the highest number of trial plans, whereas February has the lowest number of trial plans.


#3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.
#Question is asking for the number of plans for start dates occurring on 1 Jan 2021 and after grouped by plan names.
SELECT s.plan_id,p.plan_name, COUNT(*) AS events_2021
FROM 
subscriptions s JOIN
plans p ON s.plan_id = p.plan_id
WHERE s.start_date >='2021-01-01'
GROUP BY s.plan_id, p.plan_name;

#There were 0 customer on trial plan in 2021. Does it mean that there were no new customers in 2021, or did they jumped on basic monthly plan without going through the 7-week trial?

#extra
SELECT 
  s.plan_id,
  p.plan_name,
  SUM(
    CASE WHEN s.start_date <= '2020-12-31' THEN 1
    ELSE 0 END) AS events_2020,
  SUM(
    CASE WHEN s.start_date >= '2021-01-01' THEN 1
    ELSE 0 END) AS events_2021
FROM foodie_fi.subscriptions s
JOIN foodie_fi.plans p
  ON s.plan_id = p.plan_id
GROUP BY s.plan_id, p.plan_name
ORDER BY s.plan_id;


#4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT COUNT(distinct(s.customer_id)),
SUM(
   CASE WHEN s.plan_id = 4 THEN 1
   ELSE 0 END) as total_churn,
ROUND(SUM(
   CASE WHEN s.plan_id = 4 THEN 1
   ELSE 0 END)/COUNT(distinct(s.customer_id)),1)*100 AS churn_rate
FROM subscriptions s;

#or

SELECT 
  COUNT(*) AS churn_count,
  ROUND(100 * COUNT(*) / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM foodie_fi.subscriptions),1) AS churn_percentage
FROM foodie_fi.subscriptions s
JOIN foodie_fi.plans p
  ON s.plan_id = p.plan_id
WHERE s.plan_id = 4;

#There are 307 customers who have churned, which is 30.7% of Foodie-Fi customer base.

#5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
CREATE TEMPORARY TABLE churn_rank_cte
SELECT s.customer_id, s.plan_id, p.plan_name,
ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.start_date) AS churn_rank
FROM subscriptions s 
JOIN plans p ON s.plan_id = p.plan_id;

SELECT * FROM churn_rank_cte;

SELECT COUNT(*) as churn_count,
ROUND(100 * COUNT(*) / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM subscriptions),0) AS churn_percentage
FROM churn_rank_cte
WHERE plan_id=4 AND churn_rank=2;

#92 or 9% customers left after the trail .


#6.  What is the number and percentage of customer plans after their initial free trial?

#this is giving the ans for the number of cust who joined after the initial trial
SELECT COUNT(*) as cust_plan_count,
ROUND(100 * COUNT(*) / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM subscriptions),0) AS plan_pct
FROM churn_rank_cte
WHERE plan_id!=4 AND churn_rank=2;

#91% cust joined after inital phase.


CREATE TEMPORARY TABLE next_plan_cte 
SELECT 
  customer_id, 
  plan_id, 
  LEAD(plan_id, 1) OVER( -- Offset by 1 to retrieve the immediate row's value below 
    PARTITION BY customer_id 
    ORDER BY plan_id) as next_plan
FROM subscriptions;

SELECT 
  next_plan, 
  COUNT(*) AS conversions,
  ROUND(100 * COUNT(*) / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM subscriptions),1) AS conversion_percentage
FROM next_plan_cte
WHERE next_plan IS NOT NULL 
  AND plan_id = 0
GROUP BY next_plan
ORDER BY next_plan;

#More than 80% of customers are on paid plans with small 3.7% on plan 3 (pro annual $199). 
#Foodie-Fi has to strategize on their customer acquisition who would be willing to spend more.

#8. How many customers have upgraded to an annual plan in 2020?
SELECT 
  COUNT(DISTINCT customer_id) AS unique_customer
FROM subscriptions
WHERE plan_id = 3
  AND start_date <= '2020-12-31';

#195 customers upgraded to an annual plan in 2020.and


#9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?




# Filter results to customers at trial plan = 0

CREATE TEMPORARY TABLE trial_plan
SELECT 
  customer_id, 
  start_date AS trial_date
FROM subscriptions
WHERE plan_id = 0;

#Filter results to customers at pro annual plan = 3
CREATE TEMPORARY TABLE annual_plan
SELECT 
  customer_id, 
  start_date AS annual_date
FROM subscriptions
WHERE plan_id = 3;

SELECT 
  ROUND(AVG(annual_date - trial_date),0) AS avg_days_to_upgrade
FROM trial_plan tp
JOIN annual_plan ap
  ON tp.customer_id = ap.customer_id;

#On average, it takes 105 days for a customer to upragde to an annual plan from the day they join Foodie-Fi.


#11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020? 
#-- To retrieve next plan's start date located in the next row based on current row
WITH next_plan_cte AS (
SELECT 
  customer_id, 
  plan_id, 
  start_date,
  LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY plan_id) as next_plan
FROM foodie_fi.subscriptions)

SELECT 
  COUNT(*) AS downgraded
FROM next_plan_cte
WHERE start_date <= '2020-12-31'
  AND plan_id = 2 
  AND next_plan = 1;
  
  #No customer has downgrade from pro monthly to basic monthly in 2020.










