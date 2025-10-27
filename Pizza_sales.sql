CREATE DATABASE Pizza_sales;
USE Pizza_sales;

-- Retrieve the total number of order placed.
SELECT COUNT(order_id) AS Total_orders FROM orders;

-- Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(order_details.quantity *pizzas.price),2) AS Total_revenue
FROM  order_details JOIN pizzas
ON pizzas.pizza_id = order_details.pizza_id;

-- Identify the highest-priced pizza.
SELECT pizza_types.name, pizzas.price
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT pizzas.size, COUNT(order_details.order_details_id) AS Order_count
FROM pizzas JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY Order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name, SUM(order_details.quantity ) AS Quantity
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details 
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Quantity DESC LIMIT 5 ;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types.category, SUM(order_details.quantity) AS Quantity
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT HOUR(time), COUNT(order_id) AS Order_counts FROM  orders
GROUP BY HOUR(time);

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(name) FROM pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT AVG(Quantity)AS Avg_ordered_per_day FROM 
(SELECT orders.date, SUM(order_details.quantity) AS Quantity
FROM orders JOIN order_details
ON orders.order_id = order_details.order_id
GROUP BY orders.date) AS order_quantity ;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT pizza_types.name, SUM(order_details.quantity*pizzas.price) AS Revenue
FROM pizza_types JOIN pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
 SELECT pizza_types.category, ROUND(SUM(order_details.quantity*pizzas.price) / (SELECT ROUND(SUM(order_details.quantity*pizzas.price),2)
 FROM order_details
 JOIN pizzas
 ON pizzas.pizza_id = order_details.pizza_id) *100,2) AS Revenue
FROM pizza_types JOIN pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Revenue DESC ;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name, revenue FROM
(SELECT category, name, revenue,
RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS RO
FROM
(SELECT pizza_types.category, pizza_types.name, 
SUM(order_details.quantity*pizzas.price) AS revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) AS A) AS B
WHERE RO >=3 ;
