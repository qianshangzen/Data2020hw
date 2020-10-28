
-------------------- Single entity --------------------

-- 1. Prepare a list of offices sorted by country, state, city. 
select * from classicmodels.offices order by country;
select * from classicmodels.offices order by state;
select * from classicmodels.offices order by city;

-- 2. How many employees are there in the company? 23
select count(employeeNumber) from classicmodels.employees;

-- 3. What is the total of payments received? 273
select count(distinct checkNumber) from payments;

-- 4. List the product lines that contain 'Cars'.
select * from products where productLine like '%Cars%';

-- 5. Report total payments for October 28, 2004. 47411.33
select sum(amount) from payments where paymentDate = '2004-10-28';

-- 6. Report those payments greater than $100,000.
select * from payments where amount > 100000;

-- 7. List the products in each product line.
select productLine, 
		group_concat(productCode order by productCode asc separator ','), 
		group_concat(productName order by productCode asc separator ',') 
from products 
group by productLine;

-- 8. How many products in each product line?
select productLine, count(distinct productCode) 
from products
group by productLine;

-- 9. What is the minimum payment received? 615.45
select min(amount)
from payments;

-- 10. List all payments greater than twice the average payment.
select *
from payments p, 
	(select avg(amount) average
		from payments) t
where p.amount > 2*t.average;


-- 11. What is the average percentage markup of the MSRP on buyPrice?
select round(avg((MSRP-buyPrice)/buyPrice)*100, 2) 
from products;


-- 12. How many distinct products does ClassicModels sell? 110
select count(productCode)
from products;

-- 13. Report the name and city of customers who don't have sales representatives?
select customerName name, city
from customers
where isnull(salesRepEmployeeNumber);

-- 14. What are the names of executives with VP or Manager in their title? 
--     Use the CONCAT function to combine the employee's first name and last name into a single field for reporting.
select firstName, lastName
from employees
where jobTitle like '%VP%' or jobTitle like '%Manager%';

-- 15. Which orders have a value greater than $5,000?
select o2.orderNumber
from orderdetails o2
where orderNumber 
group by o2.orderNumber
having sum(o2.quantityOrdered * o2.priceEach) > 5000;


-------------------- One to many relationship --------------------

-- 1. Report the account representative for each customer.
select c.customerNumber, c.customerName, e.employeeNumber, concat(e.firstName, ', ', e.lastName)
from customers c, employees e
where c.salesRepEmployeeNumber = e.employeeNumber;

-- 2. Report total payments for Atelier graphique.
select c.customerNumber, sum(p.amount) 'total payments'
from customers c, payments p
where c.customerNumber = p.customerNumber and
	c.customerName = 'Atelier graphique'
group by c.customerNumber;

-- 3. Report the total payments by date.
select paymentDate, sum(amount)
from payments
group by paymentDate;

-- 4. Report the products that have not been sold.
select *
from products p
where p.productCode not in (select distinct productCode from orderdetails);

-- 5. List the amount paid by each customer.
select customerNumber, sum(amount)
from payments
group by customerNumber;

-- 6. How many orders have been placed by Herkku Gifts?
select count(*)
from customers c, orders o
where c.customerName = 'Herkku Gifts' and 
	c.customerNumber = o.customerNumber;

-- 7. Who are the employees in Boston?
select *
from employees e, offices o
where e.officeCode = o.officeCode and
	o.city = 'Boston';

-- 8. Report those payments greater than $100,000. Sort the report so the customer who made the highest payment appears first.
select c.customerNumber, c.customerName, p.amount
from customers c, payments p
where p.amount > 100000 and p.customerNumber = c.customerNumber
order by p.amount desc;

-- 9. List the value of 'On Hold' orders.
select o1.orderNumber, o1.status, sum(o2.quantityOrdered * o2.priceEach)
from orders o1, orderdetails o2
where o1.status = 'On Hold' and o1.orderNumber = o2.orderNumber
group by o1.orderNumber;

-- 10. Report the number of orders 'On Hold' for each customer.
select c.customerNumber, count(o.orderNumber)
from orders o, customers c
where o.customerNumber = c.customerNumber and o.status = 'On Hold'
group by c.customerNumber;


-------------------- Many to many relationship --------------------

-- 1. List products sold by order date.
select o1.orderNumber, o1.orderDate, p.productCode, p.productName
from orders o1, orderdetails o2, products p
where o1.orderNumber = o2.orderNumber and o2.productCode = p.productCode
order by o1.orderDate;

-- 2. List the order dates in descending order for orders for the 1940 Ford Pickup Truck.
select o1.orderDate
from orders o1, orderdetails o2, products p
where o1.orderNumber = o2.orderNumber and o2.productCode = p.productCode and p.productName = '1940 Ford Pickup Truck'
order by o1.orderDate desc;

-- 3. List the names of customers and their corresponding order number 
--    where a particular order from that customer has a value greater than $25,000?
select c.customerNumber, c.customerName, o1.orderNumber
from customers c, orders o1, orderdetails o2 
where c.customerNumber = o1.customerNumber and o1.orderNumber = o2.orderNumber 
group by o1.orderNumber
having sum(quantityOrdered*priceEach) > 25000;

-- 4. Are there any products that appear on all orders? no
select *
from orderdetails o, products p
where o.productCode = p.productCode
group by p.productCode
having count(o.orderNumber) = (select count(*) from orders);

-- 5. List the names of products sold at less than 80% of the MSRP.
select distinct o.productCode, p.productName
from products p, orderdetails o
where o.productCode = p.productCode and o.priceEach >= p.MSRP*0.8;


-- 6. Reports those products that have been sold with a markup of 100% or more 
--    (i.e.,  the priceEach is at least twice the buyPrice)
select distinct p.productCode, p.productName
from products p, orderdetails o
where o.productCode = p.productCode and o.priceEach >= 2*p.buyPrice;

-- 7. List the products ordered on a Monday.
select distinct p.productCode, p.productName
from orders o1, orderdetails o2, products p
where o1.orderNumber = o2.orderNumber and o2.productCode = p.productCode and DAYNAME(o1.orderDate) = 'Monday';

-- 8. What is the quantity on hand for products listed on 'On Hold' orders? 
select count(p.productCode)
from orders o1, orderdetails o2, products p
where o1.orderNumber = o2.orderNumber and o2.productCode = p.productCode and status = 'On Hold';


-------------------- Regular expressions --------------------

-- 1. Find products containing the name 'Ford'.
select *
from products 
where productName like '%Ford%';

-- 2. List products ending in 'ship'.
select *
from products 
where productName regexp 'ship$';

-- 3. Report the number of customers in Denmark, Norway, and Sweden.
select *
from customers 
where country regexp 'Denmark|Norway|Sweden';

-- 4. What are the products with a product code in the range S700_1000 to S700_1499?
select *
from products 
where productCode regexp 'S700_1[0-4][0-9]{2}';

-- 5. Which customers have a digit in their name?
select *
from customers
where customerName regexp '.*[0-9].*';

-- 6. List the names of employees called Dianne or Diane.
select *
from employees
where firstName regexp 'Dian{1,2}e' or lastName regexp 'Dianne|Diane' ;

-- 7. List the products containing ship or boat in their product name.
select *
from products
where productName regexp '.*ship|boat.*';

-- 8. List the products with a product code beginning with S700.
select *
from products 
where productCode regexp '^S700';

-- 9. List the names of employees called Larry or Barry.
select *
from employees
where firstName regexp '[LB]arry' or lastName regexp '[LB]arry';

-- 10. List the names of employees with non-alphabetic characters in their names. 
select *
from employees
where firstName regexp '\\W' or lastName regexp '\\W';

-- 11. List the vendors whose name ends in Diecast
select *
from products 
where productVendor regexp 'Diecast$';


-------------------- General queries --------------------

-- 1. Who is at the top of the organization (i.e.,  reports to no one).
select *
from employees
where reportsTo is null;

-- 2. Who reports to William Patterson?
select *
from employees
where reportsTo = (select employeeNumber from employees where firstName = 'William' and lastName = 'Patterson');

-- 3. List all the products purchased by Herkku Gifts.
select distinct p.productCode
from customers c, orders o1, orderdetails o2, products p
where c.customerName = 'Herkku Gifts' and 
		o1.customerNumber = c.customerNumber and 
        o1.orderNumber = o2.orderNumber and 
		p.productCode = o2.productCode;

-- 4. Compute the commission for each sales representative, 
--    assuming the commission is 5% of the value of an order. 
--    Sort by employee last name and first name.
select c.salesRepEmployeeNumber, e.lastName, e.firstName, 0.05*sum(priceEach*quantityOrdered) commission
from customers c, employees e, orders o1, orderdetails o2
where c.salesRepEmployeeNumber = e.employeeNumber and 
		c.customerNumber = o1.customerNumber and
        o1.orderNumber = o2.orderNumber
group by c.salesRepEmployeeNumber
order by e.lastName, e.firstName;

-- 5. What is the difference in days between the most recent and oldest order date in the Orders file?
select datediff(max(orderDate), min(orderDate))
from orders;


-- 6. Compute the average time between order date and ship date for each customer ordered by the largest difference.
select customerNumber, avg(datediff(shippedDate,orderDate)) diff_days
from orders
group by customerNumber
order by diff_days desc;

-- 7. What is the value of orders shipped in August 2004? (Hint).
select date_format(shippedDate, '%Y-%m'), sum(priceEach * quantityOrdered)
from orders o1, orderdetails o2
where o1.orderNumber = o2.orderNumber and date_format(shippedDate, '%Y-%m') = '2004-08';


-- 8. Compute the total value ordered, total amount paid, and their difference for each customer for orders placed in 2004 
--    and payments received in 2004 
--    (Hint; Create views for the total paid and total ordered).

select t1.customerNumber, t1.total_order_value, t2.total_payment, t1.total_order_value - t2.total_payment difference
from (select o1.customerNumber, sum(o2.priceEach*o2.quantityOrdered) total_order_value
		from orders o1, orderdetails o2, customers c
		where year(o1.orderDate) = '2004' and
			o1.orderNumber = o2.orderNumber and 
			o1.customerNumber = c.customerNumber
		group by o1.customerNumber) t1, 
		(select c.customerNumber, sum(amount) total_payment
		from customers c, payments p
		where c.customerNumber = p.customerNumber and year(paymentDate) = '2004'
		group by c.customerNumber) t2
where t1.customerNumber = t2.customerNumber;

-- 9. List the employees who report to those employees who report to Diane Murphy. 
--    Use the CONCAT function to combine the employee's first name and last name into a single field for reporting.
select employeeNumber, concat(firstName, ', ', lastName)
from employees
where reportsTo in (select employeeNumber
					from employees
					where reportsTo = 
							(select employeeNumber from employees where concat(firstName, ' ', lastName) = 'Diane Murphy')
                    );

-- 10. What is the percentage value of each product in inventory sorted by the highest percentage first 
--    (Hint: Create a view first).
select productCode, productName, quantityInStock, round(quantityInStock/(select sum(quantityInStock) from products)*100,2) percentage
from products
order by percentage desc;

-- 11. Write a function to convert miles per gallon to liters per 100 kilometers.
delimiter $$
create function convert_mp_to_kp (mp float)
returns float 
begin 
	declare kp float;
    set kp = mp * 235.215;
    return kp;
end$$
delimiter ;
show function status
where db = 'classicmodels';
select convert_mp_to_kp(1);


-- 12. Write a procedure to  of a speincrease the pricecified product category by a given percentage. 
--    You will need to create a product table with appropriate data to test your procedure. 
--    Alternatively, load the ClassicModels database on your personal machine so you have complete access. 
--    You have to change the DELIMITER prior to creating the procedure.
delimiter $$
drop procedure if exists increase_price;
create procedure increase_price(product_line VARCHAR(50), percentage float)
begin
	select productCode, productName, productLine, productScale, 
			productVendor, productDescription, quantityInStock, buyPrice,
            MSRP * (1+percentage*0.01)
    from products 
    where productLine = product_line
    union 
    select * 
    from products 
    where productLine != product_line;
end$$
delimiter ;
show procedure status
where db = 'classicmodels';

call increase_price('Vintage Cars', 5);


-- 13. What is the value of orders shipped in August 2004? (Hint).
select date_format(shippedDate, '%Y-%m'), sum(priceEach * quantityOrdered)
from orders o1, orderdetails o2
where o1.orderNumber = o2.orderNumber and date_format(shippedDate, '%Y-%m') = '2004-08';

-- 14. What is the ratio the value of payments made to orders received for each month of 2004.
--    (i.e., divide the value of payments made by the orders received)?
select t1.paymentDate, t1.total_pay/t2.total_value
from (select date_format(paymentDate, '%Y-%m') paymentDate, sum(amount) total_pay
		from payments
		where year(paymentDate) = '2004'
		group by date_format(paymentDate, '%Y-%m')) t1,
		(select date_format(o1.orderDate, '%Y-%m') orderDate, sum(o2.priceEach*quantityOrdered) total_value
		from orders o1, orderdetails o2
		where year(o1.orderDate) = '2004' and o1.orderNumber = o2.orderNumber
		group by date_format(o1.orderDate, '%Y-%m')) t2
where t1.paymentDate = t2.orderDate
order by t1.paymentDate;

-- 15. What is the difference in the amount received for each month of 2004 compared to 2003?
select (select sum(amount) from payments where year(paymentDate) = '2004') - 
	(select sum(amount) from payments where year(paymentDate) = '2003');

-- 16. Write a procedure to report the amount ordered in a specific month and year 
--    for customers containing a specified character string in their name.
delimiter $$
drop procedure if exists amount_inyrmo;
create procedure amount_inyrmo(mo int, yr int)
begin
	select date_format(orderDate, '%Y-%m') date, sum(o2.priceEach*quantityOrdered) amount
    from orders o1, orderdetails o2
    where o1.orderNumber = o2.orderNumber and year(orderDate) = yr and month(orderDate) = mo;
end $$
delimiter ;
show procedure status where db = 'classicmodels';

call amount_inyrmo(05, 2004);

-- 17. Write a procedure to change the credit limit of all customers in a specified country by a specified percentage.
delimiter $$
drop procedure if exists change_limit;
create procedure change_limit(c varchar(50), percentage float)
begin
	select customerNumber, customerName, contactLastName, contactFirstName, phone, addressLine1, 
			addressLine2, city, state, postalCode, country, salesRepEmployeeNumber, 
            round(creditLimit * percentage,2) creditLimit
    from customers
    where country = c
    union
    select *
    from customers
    where country != c;
end $$
delimiter ;

call change_limit('France', 1.05);

-- 18. Basket of goods analysis: A common retail analytics task is to analyze each basket or order to 
--    learn what products are often purchased together. 
--    Report the names of products that appear in the same order ten or more times.
/* Example
create view temp as
select 1 num, 'a' col
union 
select 1 num, 'b' col
union 
select 2 num, 'a' col
union 
select 2 num, 'c' col
union 
select 3 num, 'a' col
union 
select 3 num, 'b' col
union 
select 3 num, 'c' col
union 
select 4 num, 'b' col
union 
select 5 num, 'a' col
union 
select 5 num, 'b' col;
select * from temp;

select t1.col, t2.col, count(t1.num)
from temp t1, temp t2
where t1.num = t2.num and t1.col < t2.col
group by t1.col, t2.col;
*/

drop view if exists temp_tab;
create view temp_tab as
select o1.orderNumber, o2.productCode
from orders o1, orderdetails o2
where o1.orderNumber = o2.orderNumber;

drop view if exists temp_tab2;
create view temp_tab2 as
select t1.productCode t1p, t2.productCode t2p, count(t1.orderNumber)
from temp_tab t1, temp_tab t2
where t1.orderNumber = t2.orderNumber and t1.productCode < t2.productCode
group by t1.productCode, t2.productCode
having count(t1.orderNumber) >= 10;

select t1p from temp_tab2
union 
select t2p from temp_tab2;

-- 19. ABC reporting: Compute the revenue generated by each customer based on their orders. 
--    Also, show each customer's revenue as a percentage of total revenue. Sort by customer name.
select c.customerNumber, c.customerName, sum(o2.quantityOrdered*o2.priceEach) revenue,
	round(sum(o2.quantityOrdered*o2.priceEach)/(select sum(quantityOrdered*priceEach) from orderdetails)*100,2) revenue_percentage
from orders o1, orderdetails o2, customers c
where o1.orderNumber = o2.orderNumber and c.customerNumber = o1.customerNumber
group by c.customerNumber
order by c.customerName;


-- 20. Compute the profit generated by each customer based on their orders. 
--    Also, show each customer's profit as a percentage of total profit. Sort by profit descending.
select c.customerNumber, c.customerName, sum(o2.quantityOrdered*(o2.priceEach-p.buyPrice)) profit
from orders o1, orderdetails o2, customers c, products p
where o1.orderNumber = o2.orderNumber and c.customerNumber = o1.customerNumber and o2.productCode = p.productCode
group by c.customerNumber
order by profit desc;


-- 21. Compute the revenue generated by each sales representative based on the orders from the customers they serve.
select c.salesRepEmployeeNumber, sum(o2.quantityOrdered*o2.priceEach) revenue
from orders o1, orderdetails o2, customers c
where o1.orderNumber = o2.orderNumber and c.customerNumber = o1.customerNumber
group by c.salesRepEmployeeNumber
order by profit desc;

-- 22. Compute the profit generated by each sales representative based on the orders from the customers they serve. 
--    Sort by profit generated descending.
select c.salesRepEmployeeNumber, sum(o2.quantityOrdered*(o2.priceEach-p.buyPrice)) profit
from orders o1, orderdetails o2, customers c, products p
where o1.orderNumber = o2.orderNumber and c.customerNumber = o1.customerNumber and o2.productCode = p.productCode
group by c.salesRepEmployeeNumber
order by profit desc;

-- 23. Compute the revenue generated by each product, sorted by product name.
select p.productCode, p.productName, sum(o2.quantityOrdered*o2.priceEach) revenue
from products p, orders o1, orderdetails o2
where o1.orderNumber = o2.orderNumber and o2.productCode = p.productCode
group by p.productCode
order by p.productName;

-- 24. Compute the profit generated by each product line, sorted by profit descending.
select p.productLine, sum(o2.quantityOrdered*(o2.priceEach - p.buyPrice)) profit
from products p, orders o1, orderdetails o2
where o1.orderNumber = o2.orderNumber and o2.productCode = p.productCode
group by p.productLine
order by profit desc;

-- 25. Same as Last Year (SALY) analysis: Compute the ratio for each product of sales for 2003 versus 2004.
select productCode, sum(if(yr = 2003, sales, 0))/sum(if(yr = 2004, sales, 0))
from (select p.productCode, year(o1.orderDate) yr, sum(o2.quantityOrdered) sales
		from products p, orders o1, orderdetails o2
		where o1.orderNumber = o2.orderNumber and o2.productCode = p.productCode and 
				(year(o1.orderDate) = 2003 or year(o1.orderDate) = 2004)
		group by p.productCode, year(o1.orderDate)) t
group by productCode
having count(*) = 2;

-- 26. Compute the ratio of payments for each customer for 2003 versus 2004.
select customerNumber, sum(if(yr = 2003, amount, 0))/sum(if(yr = 2004, amount, 0))
from (select c.customerNumber, year(p.paymentDate) yr, sum(p.amount) amount
		from customers c, payments p
		where c.customerNumber = p.customerNumber and (year(p.paymentDate) = 2003 or year(p.paymentDate) = 2004)
		group by c.customerNumber, year(p.paymentDate)) t
group by customerNumber
having count(*) = 2;

-- 27. Find the products sold in 2003 but not 2004.
select productCode
from products 
where productCode in
		(select distinct p.productCode
		from products p, orders o1, orderdetails o2
		where o1.orderNumber = o2.orderNumber and o2.productCode = p.productCode and
				year(o1.orderDate) = 2003) 
		and
		productCode not in
		(select distinct p.productCode
		from products p, orders o1, orderdetails o2
		where o1.orderNumber = o2.orderNumber and o2.productCode = p.productCode and
				year(o1.orderDate) = 2004);

-- 28. Find the customers without payments in 2003.
select *
from customers
where customerNumber not in (select c.customerNumber
								from customers c, payments p
								where year(p.paymentDate) = 2003 and c.customerNumber = p.customerNumber);



-------------------- Correlated subqueries --------------------                                

-- 1. Who reports to Mary Patterson?
select *
from employees
where reportsTo = (select employeeNumber from employees where lastName = 'Patterson' and firstName = 'Mary');

-- 2. Which payments in any month and year are more than twice the average for that month and year 
--    (i.e. compare all payments in Oct 2004 with the average payment for Oct 2004)? 
--    Order the results by the date of the payment. You will need to use the date functions.
select date_format(paymentDate, '%Y-%m') paymentDate
from payments 
group by date_format(paymentDate, '%Y-%m')
having sum(amount) > 2*avg(amount);

-- 3. Report for each product, 
--    the percentage value of its stock on hand as a percentage of the stock on hand for product line to which it belongs. 
--    Order the report by product line and percentage value within product line descending. 
--    Show percentages with two decimal places.   
select p.productCode, p.productName, p.productLine, round(p.quantityInStock/t.stock*100, 2) percentage_of_stock
from products p,
	(select productLine, sum(quantityInStock) stock
	from products
	group by productLine) t
where p.productLine = t.productLine
order by p.productLine, percentage_of_stock desc;

-- 4. For orders containing more than two products, 
--    report those products that constitute more than 50% of the value of the order.
select *
from orderdetails
group by orderNumber
having count(*) >= 2 and quantityOrdered*priceEach >= 0.5*sum(quantityOrdered*priceEach);


-------------------- Spatial data --------------------         

-- 1. Which customers are in the Southern Hemisphere?
select *
from customers
where 

-- 2. Which US customers are south west of the New York office?


-- 3. Which customers are closest to the Tokyo office (i.e., closer to Tokyo than any other office)?


-- 4. Which French customer is furthest from the Paris office?


-- 5. Who is the northernmost customer?


-- 6. What is the distance between the Paris and Boston offices?
--    To be precise for long distances, the distance in kilometers, as the crow flies, 
--    between two points when you have latitude and longitude, 
--    is (ACOS(SIN(lat1*PI()/180)*SIN(lat2*PI()/180)+COS(lat1*PI()/180)*COS(lat2*PI()/180)* COS((lon1-lon2)*PI()/180))*180/PI())*60*1.8532




