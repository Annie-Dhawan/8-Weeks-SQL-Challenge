/*
--------------------------------

--CASE STUDY #1: DANNY'S DINER--

--------------------------------

--Author: Annie Dhawann
--Date: 09/12/2022
--Tool used: MySQL 
*/



#creating db with the name dannys_diner
CREATE DATABASE dannys_diner;

#command to use this db
USE dannys_diner;

#creating table sales
CREATE TABLE sales(
customer_id VARCHAR(1),
order_date DATE,
product_id INT
);


#creating table menu
CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

#creating table members
CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  
  
  INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
  
  INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
/*
=-----------------------
--CASE STUDY QUESTIONS--
------------------------ 
*/

#1. What is the total amount each customer spent at the restaurant?
SELECT sales.customer_id, SUM(menu.price) AS total_sales FROM
sales INNER JOIN
menu 
ON sales.product_id = menu.product_id
GROUP BY sales.customer_id;

#2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT(order_date))
FROM sales
GROUP BY customer_id;

#3. What was the first item from the menu purchased by each customer?
#we are going to use partition by here, basically we are just partitioning the rows on the basis of cutomer_id
#here we are firstly creating a temp table and ranking our dates
CREATE TEMPORARY TABLE temp_rank_table
SELECT sales.customer_id, sales.order_date, menu.product_name,
DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date asc) AS 'rank1'
FROM sales JOIN
menu on sales.product_id = menu.product_id;

SELECT * FROM temp_rank_table;

SELECT customer_id, product_name,rank1
FROM temp_rank_table
WHERE rank1=1
GROUP BY customer_id, product_name;


#4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT COUNT(sales.product_id),product_name
FROM sales JOIN
menu on sales.product_id=menu.product_id
GROUP BY product_name,sales.product_id
ORDER BY count(customer_id) DESC LIMIT 1;


#5. Which item was the most popular for each customer?
#1st partiiton by on customer_id
#2nd count of product_id group by productid

CREATE TEMPORARY TABLE pop_product_table 
SELECT sales.customer_id, menu.product_name,
COUNT(sales.product_id) AS order_count,
DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY COUNT(sales.customer_id) DESC) AS "rank2"
FROM sales JOIN 
menu ON sales.product_id = menu.product_id
GROUP BY sales.customer_id, menu.product_name;

SELECT * FROM pop_product_table;

SELECT customer_id,product_name,order_count
FROM pop_product_table
WHERE rank2=1;



#6. Which item was purchased first by the customer after they became a member?
#we need to write joining date for each customer, this can be done by joining tables sales,members
CREATE TEMPORARY TABLE first_purchased_temp_table 
SELECT sales.customer_id,sales.product_id,sales.order_date,members.join_date,
DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date) AS 'rank3'
FROM sales
JOIN members 
ON sales.customer_id = members.customer_id
WHERE sales.order_date >= members.join_date;

SELECT * FROM first_purchased_temp_table ;

SELECT s1.customer_id, s1.order_date, m2.product_name , s1.rank3
FROM first_purchased_temp_table AS s1
JOIN menu AS m2
ON s1.product_id = m2.product_id
WHERE rank3 = 1
ORDER BY s1.customer_id;



#7. Which item was purchased just before the customer became a member?
CREATE TEMPORARY TABLE first_purchased_temp_table_before_mem 
SELECT sales.customer_id, sales.product_id, sales.order_date, members.join_date,
DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date) AS 'rank4'
FROM sales
JOIN members 
ON sales.customer_id = members.customer_id
WHERE sales.order_date < members.join_date;

SELECT * FROM first_purchased_temp_table_before_mem;

SELECT s1.customer_id, s1.order_date, m2.product_name , s1.rank4
FROM first_purchased_temp_table_before_mem AS s1
JOIN menu AS m2
ON s1.product_id = m2.product_id
WHERE rank4 = 1
ORDER BY s1.customer_id;


#8. What is the total items and amount spent for each member before they became a member?

SELECT s1.customer_id, COUNT(s1.product_id) AS total_items, SUM(m2.price) AS Total_Amount_Spent
FROM first_purchased_temp_table_before_mem AS s1
JOIN menu AS m2
ON s1.product_id = m2.product_id 
GROUP BY s1.customer_id;



#9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?
CREATE TEMPORARY TABLE pointers 
SELECT *,
CASE
    WHEN product_id = 1 THEN price*20
    ELSE price*10
    END AS points
FROM menu;

SELECT * FROM POINTERS;

SELECT s.customer_id, SUM(p.points) FROM 
sales s JOIN pointers p
ON s.product_id = p.product_id
GROUP BY s.customer_id;



/*10. In the first week after a customer joins the program (including their join date) they earn
 2x points on all items, not just sushi — how many points do customer A and B have at the end of January? */
 
 create temporary table points_table_temp 
 SELECT s.customer_id,s.order_date,s.product_id,m.join_date ,m1.price,
 CASE
     WHEN DATEDIFF(s.order_date , m.join_date)<=0 THEN price*10
     WHEN DATEDIFF(s.order_date , m.join_date)>0 AND DATEDIFF(s.order_date , m.join_date)<7 THEN price*20
     ELSE price*10
END AS points
 FROM
 sales s JOIN members m
 ON s.customer_id = m.customer_id
 JOIN menu m1
 ON s.product_id = m1.product_id;
 

 select * from points_table_temp;
 
 CREATE TEMPORARY TABLE moving_sum_temp SELECT * ,
 SUM(points) OVER(PARTITION BY customer_id ORDER BY order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_sum
 FROM points_table_temp;
 
 SELECT * FROM moving_sum_temp;
 
 #finding out the points for each 
 SELECT customer_id, sum(moving_sum)
 FROM moving_sum_temp
 WHERE order_date<"2021-01-30"
 GROUP BY customer_id;
 


 #Q11. Joining all the tables together 
CREATE TEMPORARY TABLE summary_temp SELECT s.customer_id, s.order_date, m.product_name, m.price,
 CASE
     WHEN mem.join_date <= S.order_date THEN 'YES'
     WHEN mem.join_date > S.order_date THEN 'NO'
     ELSE 'NO'
END AS member
 FROM sales s LEFT JOIN
 menu m ON s.product_id = m.product_id
 LEFT JOIN members AS mem
 ON s.customer_id = mem.customer_id;
 
 SELECT * FROM summary_temp;
 
 
 
 #12. 
 SELECT *,
 CASE 
     WHEN summary_temp.member = 'NO' THEN NULL
     ELSE 
         RANK() OVER(PARTITION BY customer_id,member ORDER BY order_date) 
	END AS ranking
FROM summary_temp;
 

 

 
 



















