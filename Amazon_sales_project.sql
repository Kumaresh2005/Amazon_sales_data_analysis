
-------------------- *****amazon_sales_data_analysis**** -----------------------------
create database Amazon_sales_data;
use Amazon_sales_data;

-------------------- Data Cleanning -----------------------------

-- step 01 : Check for null values
SELECT *
FROM sales_dataset
WHERE product_category IS NULL
   OR price IS NULL
   OR quantity_sold IS NULL;

-- step 02 : Check duplicate orders
SELECT order_id, COUNT(*) AS duplicate_count
FROM sales_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;

-------------------------- Data analysis Part ------------------------

                     -- Total revenue
SELECT round(SUM(total_revenue),2) AS total_sales
FROM sales_dataset;

-- total unit sold
select sum(quantity_sold) 
from sales_dataset;

-- DISTINCT category for product
SELECT DISTINCT product_category
FROM sales_dataset;

-- DISTINCT customer_region
SELECT DISTINCT customer_region
FROM sales_dataset;


----------------------------- aggregation functions ------------------------

-- Total Quantity Sold Per Category
SELECT
    product_category,
    SUM(quantity_sold) AS total_quantity
FROM sales_dataset
GROUP BY product_category
ORDER BY total_quantity DESC;

-- Average Discount Per Region
SELECT
    customer_region,
    ROUND(AVG(discount_percent), 2) AS avg_discount
FROM sales_dataset
GROUP BY customer_region;

-- Highest and Lowest Price Per Category
SELECT
    product_category,
    MAX(price) AS highest_price,
    MIN(price) AS lowest_price
FROM sales_dataset
GROUP BY product_category;

-- Total Orders Per Payment Method
SELECT
    payment_method,
    COUNT(order_id) AS total_orders
FROM sales_dataset
GROUP BY payment_method
ORDER BY total_orders DESC;

-- Average Rating and Total Reviews Per Category
SELECT
    product_category,
    ROUND(AVG(rating), 2) AS avg_rating,
    SUM(review_count) AS total_reviews
FROM sales_dataset
GROUP BY product_category;


----------------- window function---------------

-- Ranking product category orders by revenue
SELECT
    product_category,
    SUM(total_revenue) AS category_revenue,
    RANK() OVER (ORDER BY SUM(total_revenue) DESC) AS revenue_rank
FROM sales_dataset
GROUP BY product_category;


          -- top 3 Rank products within each category
SELECT *
FROM (
    SELECT
        product_category,
        product_id,
        total_revenue,
        RANK() OVER (PARTITION BY product_category
            ORDER BY total_revenue DESC
        ) AS category_rank
    FROM sales_dataset
) ranked_data
WHERE category_rank <= 3;


       -- Top 3 products per category
SELECT *
FROM (
    SELECT
        product_category,
        product_id,
        SUM(total_revenue) AS revenue,
        ROW_NUMBER() OVER (PARTITION BY product_category
            ORDER BY SUM(total_revenue) asc) AS rank_num
    FROM sales_dataset
    GROUP BY product_category, product_id
) ranked
WHERE rank_num <= 3;


-- Percentage contribution of each order
SELECT
    product_category,
    ROUND(SUM(total_revenue), 2) AS category_revenue,
    ROUND(SUM(total_revenue) * 100.0 /
        SUM(SUM(total_revenue)) OVER (),2) AS revenue_percent
FROM sales_dataset
GROUP BY product_category;

use amazon_sales_data;

select count(*) from sales_dataset;

-- Revenue Compared to Overall Average
SELECT
    order_id,
    total_revenue,
    ROUND(AVG(total_revenue) OVER (), 2) AS overall_avg_revenue,
    ROUND(total_revenue - AVG(total_revenue) OVER (), 2) AS difference_from_avg
FROM sales_dataset;

-------------------------------- subquery -------------------------

-- Orders Above Overall Average Revenue
SELECT
    order_id,
    total_revenue,
    (SELECT round(AVG(total_revenue),2) FROM sales_dataset) AS avg_total_revenue
FROM sales_dataset
WHERE total_revenue > (SELECT AVG(total_revenue) FROM sales_dataset);


-- Regions Having Revenue Above Overall Revenue
SELECT customer_region,
       round(SUM(total_revenue),2) AS regional_revenue,
       (SELECT round(AVG(total_revenue),2) FROM sales_dataset) AS avg_total_revenue
FROM sales_dataset
GROUP BY customer_region
HAVING SUM(total_revenue) >(SELECT AVG(total_revenue)
        FROM sales_dataset);
  
-- Average Revenue Per Category
SELECT
    category_summary.product_category,
    category_summary.avg_revenue
FROM (
    SELECT
        product_category,
        AVG(total_revenue) AS avg_revenue
    FROM sales_dataset
    GROUP BY product_category
) AS category_summary
ORDER BY category_summary.avg_revenue DESC;

 --------------------------------- join function-------------------------

-- Monthly Revenue by Product Category
SELECT 
    o.order_year,
    o.order_month,
    p.product_category,
    round(SUM(o.total_revenue),2) AS total_revenue
FROM orders o
INNER JOIN products p
    ON o.product_id = p.product_id
GROUP BY o.order_year, o.order_month, p.product_category
ORDER BY o.order_year, o.order_month;

-- Daily Sales Trend
SELECT 
    o.order_date,
    o.order_day,
    round(SUM(o.total_revenue),2) AS daily_revenue
FROM orders o
INNER JOIN products p 
    ON o.product_id = p.product_id
GROUP BY o.order_date,o.order_day
ORDER BY o.order_date,o.order_day;

-- Monthly Sales by Region
SELECT 
    o.order_year,
    o.order_month,
    o.customer_region,
    round(SUM(o.total_revenue),2) AS total_revenue
FROM orders o
INNER JOIN products p
    ON o.product_id = p.product_id
GROUP BY o.order_year, o.order_month, o.customer_region
ORDER BY o.order_year,o.order_month,o.customer_region;

-- Product Performance Analysis
SELECT 
    p.product_id,
    p.product_category,
    round(SUM(o.total_revenue),2) AS total_revenue,
    COUNT(o.order_id) AS total_orders
FROM orders o
RIGHT JOIN products p
    ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_category
ORDER BY total_revenue DESC;
-- Monthly Product Sales Comparison
SELECT 
    p.product_category,
    o.order_year,
    o.order_month,
    round(SUM(o.total_revenue),2) AS revenue
FROM orders o
lEFT JOIN products p
    ON o.product_id = p.product_id
GROUP BY 
    p.product_category,
    o.order_year,
    o.order_month
ORDER BY o.order_year, o.order_month;

SELECT 
    p.product_category,
    SUM(o.total_revenue) AS total_revenue,
    AVG(p.rating) AS avg_rating,
    AVG(p.discount_percent) AS avg_discount
FROM orders o
FULL JOIN products p
    ON o.product_id = p.product_id
GROUP BY p.product_category
ORDER BY total_revenue DESC;








   
