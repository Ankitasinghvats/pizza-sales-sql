use pizzastore;
-- Basic:
-- Retrieve the total number of orders placed.
 select count(order_id) from orders;
-- Calculate the total revenue generated from pizza sales.
select round(sum(orders_details.quantity * pizzas.price), 2) as total_sales
from orders_details join pizzas
on pizzas.pizza_id = orders_details.pizza_id;

-- Identify the highest-priced pizza.
select pizza_types.name, pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id= pizzas.pizza_type_id
order by pizzas.price desc limit 1;

-- Identify the most common pizza size ordered.
select pizzas.size, count(orders_details.order_details_id) as order_count
from pizzas join orders_details on pizzas.pizza_id = orders_details.pizza_id
group by pizzas.size
order by order_count desc;


-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name,sum(orders_details.quantity) as total_quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by total_quantity
limit 5;


-- Intermediate:
-- Join the necessary tables to find the category of each pizza  ordered.
select pizza_types.category,
sum(orders_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by quantity desc;

-- Determine the distribution of orders by hour of the day.
SELECT HOUR(order_time) AS hour, COUNT(*) AS order_count
FROM orders
GROUP BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types group by category;
-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(order_quantity), 0) AS average_quantity
FROM (
    SELECT order_date, SUM(quantity_order) AS order_quantity
    FROM (
        SELECT orders.order_date, SUM(orders_details.quantity) AS quantity_order
        FROM orders
        JOIN orders_details ON orders.order_id = orders_details.order_id
        GROUP BY orders.order_date
    ) AS order_quantity_per_day
    GROUP BY order_date
) AS aggregated_orders;

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name,sum(orders_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_details on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.name 
order by revenue desc limit 3;



-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category,
round(sum(orders_details.quantity * pizzas.price) / (SELECT SUM(orders_details.quantity * pizzas.price) AS total_sales 
FROM orders_details JOIN pizzas ON pizzas.pizza_id = orders_details.pizza_id) * 180, 2) as revenue
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by revenue desc;

-- Analyze the cumulative revenue generated over time.
select order_date,
sum(revenue) over (order by order_date) as cum_revenue from
(select orders.order_date,sum(orders_details.quantity * pizzas.price) as revenue 
from orders_details 
join pizzas on orders_details.pizza_id = pizzas.pizza_id
join orders on orders.order_id = orders_details.order_id
group by orders.order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum((orders_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id= pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;

