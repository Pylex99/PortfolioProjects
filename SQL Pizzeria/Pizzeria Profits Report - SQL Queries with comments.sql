-- Retrieving all data from the 'pizza_sales' table
SELECT * FROM pizza_sales;

-- Describing the structure of the 'pizza_sales' table
DESCRIBE pizza_sales;

-- Calculating key performance indicators (KPIs)

-- Total Revenue Calculation
SELECT SUM(total_price) AS Total_Revenue
FROM pizza_sales;
-- Result: $817,860.05

-- Average Order Value Calculation
SELECT SUM(total_price) / COUNT(DISTINCT order_id) AS Avg_Order_Value
FROM pizza_sales;
-- Result: $38.31

-- Total Pizzas Sold Calculation
SELECT SUM(quantity) AS Total_Pizza_Sold
FROM pizza_sales;
-- Result: 49,574

-- Total Number of Orders Calculation
SELECT COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales;
-- Result: 21,350

-- Average Number of Pizzas Per Order Calculation
SELECT SUM(quantity) / COUNT(DISTINCT order_id) AS Avr_Pizzas_Per_Order
FROM pizza_sales;
-- Result: 2.3220

-- -----------------------------------------------------------------------------

-- Analyzing Daily Trends for Total Orders

-- Calculating total orders for each day of the week
SELECT DAYNAME(order_date) AS order_day, COUNT(DISTINCT order_id) AS Total_orders
FROM pizza_sales
GROUP BY DAYNAME(order_date);

-- Result:
-- 'Friday', 3538 orders
-- 'Monday', 2794 orders
-- 'Saturday', 3158 orders
-- 'Sunday', 2624 orders
-- 'Thursday', 3239 orders
-- 'Tuesday', 2973 orders
-- 'Wednesday', 3024 orders

-- Fixing date format in the dataset (this part should be executed in MySQL Workbench)
-- ALTER TABLE pizza_sales
-- ADD corrected_order_date DATE;
-- UPDATE pizza_sales
-- SET corrected_order_date = STR_TO_DATE(order_date, '%d-%m-%Y');
-- ALTER TABLE pizza_sales
-- DROP COLUMN order_date;
-- ALTER TABLE pizza_sales
-- CHANGE corrected_order_date order_date DATE;

-- Calculating Monthly Trends for Orders
SELECT MONTHNAME(order_date) AS order_month, COUNT(DISTINCT order_id) AS Total_orders
FROM pizza_sales
GROUP BY MONTHNAME(order_date)
ORDER BY total_orders DESC;
-- Result:
-- 'July', 1935 orders
-- 'May', 1853 orders
-- 'January', 1845 orders
-- ... (and so on for other months)

-- -----------------------------------------------------------------------------

-- Analyzing Hourly Trend for Total Pizzas Sold

-- Calculating Total Pizzas Sold per Hour
SELECT HOUR(order_time) AS order_hours, SUM(quantity) AS total_pizzas_sold
FROM pizza_sales
GROUP BY HOUR(order_time)
ORDER BY HOUR(order_time);
# order_hours, total_pizzas_sold
-- '9', '4'
-- '10', '18'
-- '11', '2728'
-- '12', '6776'
-- '13', '6413'
-- '14', '3613'
-- '15', '3216'
-- '16', '4239'
-- '17', '5211'
-- '18', '5417'
-- '19', '4406'
-- '20', '3534'
-- '21', '2545'
-- '22', '1386'
-- '23', '68'

-- Calculating Total Orders for each Week of the Year
SELECT 
    YEAR(order_date) AS Year,
    WEEK(order_date, 3) AS WeekNumber,
    COUNT(DISTINCT order_id) AS Total_orders
FROM 
    pizza_sales
GROUP BY 
    YEAR(order_date),
    WEEK(order_date, 3)
ORDER BY 
    Year, WeekNumber;
# Year, WeekNumber, Total_orders
-- '2015', '1', '254'
-- '2015', '2', '427'
-- '2015', '3', '400'
-- '2015', '4', '415'
-- '2015', '5', '436'
-- '2015', '6', '422'
-- '2015', '7', '423'
-- '2015', '8', '393'
-- '2015', '9', '409'
-- '2015', '10', '420'
-- '2015', '11', '404'
-- '2015', '12', '416'
-- '2015', '13', '427'
-- '2015', '14', '433'
-- '2015', '15', '408'
-- '2015', '16', '414'
-- '2015', '17', '437'
-- '2015', '18', '423'
-- '2015', '19', '399'
-- '2015', '20', '458'
-- '2015', '21', '414'
-- '2015', '22', '390'
-- '2015', '23', '423'
-- '2015', '24', '418'
-- '2015', '25', '410'
-- '2015', '26', '416'
-- '2015', '27', '474'
-- '2015', '28', '417'
-- '2015', '29', '420'
-- '2015', '30', '433'
-- '2015', '31', '419'
-- '2015', '32', '426'
-- '2015', '33', '435'
-- '2015', '34', '407'
-- '2015', '35', '394'
-- '2015', '36', '397'
-- '2015', '37', '435'
-- '2015', '38', '423'
-- '2015', '39', '288'
-- '2015', '40', '433'
-- '2015', '41', '334'
-- '2015', '42', '386'
-- '2015', '43', '352'
-- '2015', '44', '371'
-- '2015', '45', '394'
-- '2015', '46', '400'
-- '2015', '47', '392'
-- '2015', '48', '491'
-- '2015', '49', '424'
-- '2015', '50', '417'
-- '2015', '51', '430'
-- '2015', '52', '298'
-- '2015', '53', '171'

-- ----------------------------------------------------

-- Calculating Percentage of Sales by Pizza Category
SELECT pizza_category, 
       ROUND(SUM(total_price), 2) AS Total_Sales,
       ROUND(SUM(total_price) / (SELECT SUM(total_price) FROM pizza_sales) * 100, 2) AS Perc_of_Total_Sales
FROM pizza_sales
GROUP BY pizza_category;
-- Result:
-- 'Classic', $220,053.10, 26.91%
-- 'Veggie', $193,690.45, 23.68%
-- 'Supreme', $208,197.00, 25.46%
-- 'Chicken', $195,919.50, 23.96%

-- Calculating Percentage of Sales by Pizza Size
SELECT 
	pizza_size, 
    ROUND(SUM(total_price), 2) AS total_revenue, 
    ROUND(SUM(total_price) / (SELECT SUM(total_price) FROM pizza_sales) * 100, 2) AS Perc_of_Total_Sales
FROM pizza_sales
GROUP BY pizza_size
ORDER BY pizza_size;
-- Result:
-- 'L', $375,318.70, 45.89%
-- 'M', $249,382.25, 30.49%
-- 'S', $178,076.50, 21.77%
-- 'XL', $14,076.00, 1.72%
-- 'XXL', $1,006.60, 0.12%

-- Calculating Total Pizzas Sold by Pizza Category
SELECT pizza_category, SUM(quantity) AS Total_Quantity_Sold
FROM pizza_sales
-- WHERE MONTH(order_date) = 2
GROUP BY pizza_category
ORDER BY Total_Quantity_Sold DESC;
-- Result:
-- 'Classic', 14888 pizzas
-- 'Supreme', 11987 pizzas
-- 'Veggie', 11649 pizzas
-- 'Chicken', 11050 pizzas

-- ------------------------------------------------------------------------

-- TOP 5

-- Top 5 Pizzas by Revenue
SELECT pizza_name, ROUND(SUM(total_price), 2) AS Total_Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Revenue DESC
LIMIT 5;
-- Result:
-- 'The Thai Chicken Pizza', $43,434.25
-- 'The Barbecue Chicken Pizza', $42,768.00
-- 'The California Chicken Pizza', $41,409.50
-- 'The Classic Deluxe Pizza', $38,180.50
-- 'The Spicy Italian Pizza', $34,831.25

-- (Similar queries for Bottom 5 Pizzas by Revenue, Quantity, and Order Count)

-- Bottom 5 Pizzas by Revenue
SELECT pizza_name, ROUND(SUM(total_price), 2) AS Total_Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Revenue ASC
LIMIT 5;
# pizza_name, Total_Revenue
-- 'The Brie Carre Pizza', '11588.5'
-- 'The Green Garden Pizza', '13955.75'
-- 'The Spinach Supreme Pizza', '15277.75'
-- 'The Mediterranean Pizza', '15360.5'
-- 'The Spinach Pesto Pizza', '15596'

-- Top 5 Pizzas by Quantity
SELECT pizza_name, SUM(quantity) AS Total_Quantity
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Quantity DESC
LIMIT 5;
# pizza_name, Total_Quantity
-- 'The Classic Deluxe Pizza', '2453'
-- 'The Barbecue Chicken Pizza', '2432'
-- 'The Hawaiian Pizza', '2422'
-- 'The Pepperoni Pizza', '2418'
-- 'The Thai Chicken Pizza', '2371'

-- Bottom 5 Pizzas by Quantity
SELECT pizza_name, SUM(quantity) AS Total_Quantity
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Quantity ASC
LIMIT 5;
# pizza_name, Total_Quantity
-- 'The Brie Carre Pizza', '490'
-- 'The Mediterranean Pizza', '934'
-- 'The Calabrese Pizza', '937'
-- 'The Spinach Supreme Pizza', '950'
-- 'The Soppressata Pizza', '961'

-- Top 5 Pizzas by Order
SELECT pizza_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Orders DESC
LIMIT 5;
# pizza_name, Total_Orders
-- 'The Classic Deluxe Pizza', '2329'
-- 'The Hawaiian Pizza', '2280'
-- 'The Pepperoni Pizza', '2278'
-- 'The Barbecue Chicken Pizza', '2273'
-- 'The Thai Chicken Pizza', '2225'

-- Bottom 5 Pizzas by Order
SELECT pizza_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Orders ASC
LIMIT 5;
# pizza_name, Total_Orders
-- 'The Brie Carre Pizza', '480'
-- 'The Mediterranean Pizza', '912'
-- 'The Calabrese Pizza', '918'
-- 'The Spinach Supreme Pizza', '918'
-- 'The Chicken Pesto Pizza', '938'

-- ----------------------------------------------------------------------------
