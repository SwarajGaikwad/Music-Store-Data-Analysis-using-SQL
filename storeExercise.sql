use music_store;
describe customer;
SELECT * FROM customer;
SELECT * FROM invoice;
SELECT count(*) from customer where company is null;

-- Question 1
SELECT employee_id, CONCAT(first_name, ' ', last_name) as Name, title 
FROM employee 
WHERE title LIKE 'Senior%';

-- Question 2
SELECT count(DISTINCT billing_country) from invoice;
SELECT billing_country, COUNT(*) as num_of_invc 
FROM invoice 
GROUP BY billing_country 
ORDER BY num_of_invc desc
LIMIT 10;

-- Question 3
SELECT *
FROM (SELECT *, DENSE_RANK() OVER(ORDER BY total desc) as value_rank FROM invoice 
		ORDER BY total desc) AS temp_table
WHERE value_rank < 4;

-- Question 4
SELECT SUM(total) as grand_sum, billing_city, billing_country
FROM customer c
Join invoice i on c.customer_id = i.customer_id
GROUP BY billing_city, billing_country
ORDER BY grand_sum desc
LIMIT 10;

-- Question 5
SELECT i.customer_id, CONCAT(c.first_name, ' ', c.last_name) as Name,SUM(total) as grand_sum
FROM customer c
Join invoice i on c.customer_id = i.customer_id
GROUP BY i.customer_id
ORDER BY grand_sum desc
LIMIT 5;

-- Question 6
SELECT DISTINCT (c.email), CONCAT(c.first_name, ' ', c.last_name) as Name
FROM customer c
JOIN invoice i On c.customer_id = i.customer_id
JOIN invoiceline il On i.invoice_id = il.invoice_id
JOIN track t On il.track_id = t.track_id
JOIN genre g On t.genre_id = g.genre_id
WHERE g.name like 'Rock'
ORDER BY c.email;

-- Question 7
SELECT ar.name as Band_name , COUNT(track_id) as count_of_tracks
FROM artist ar 
JOIN album al ON ar.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name like 'Rock'
GROUP BY ar.name
ORDER BY count_of_tracks desc
LIMIT 10;

-- Question 8
SELECT name as Track_name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds desc;
SELECT count(name)
FROM track;

-- Question 9
SELECT CONCAT(c.first_name, ' ', c.last_name) as customer_name, ar.name as artist_name , sum(i.total) as total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoiceline il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album a ON t.album_id = a.album_id
JOIN artist ar ON a.artist_id = ar.artist_id
GROUP BY customer_name, ar.name;

-- Question 10
WITH genre_stats AS
(
	SELECT c.country, g.genre_id, g.name, count(total) as num_of_purchases, 
	DENSE_RANK() OVER(PARTITION BY c.country ORDER BY c.country, count(total) desc) as rank_purchase
	FROM customer c
	JOIN invoice i ON c.customer_id = i.customer_id
	JOIN invoiceline il ON i.invoice_id = il.invoice_id
	JOIN track t ON il.track_id = t.track_id
	JOIN genre g ON t.genre_id = g.genre_id
	GROUP BY c.country, g.genre_id
)
SELECT * 
FROM genre_stats
WHERE rank_purchase = 1;

SELECT *
FROM (
	SELECT c.country, g.genre_id, g.name, count(total) as num_of_purchases, 
	DENSE_RANK() OVER(PARTITION BY c.country ORDER BY c.country, count(total) desc) as rank_purchase
	FROM customer c
	JOIN invoice i ON c.customer_id = i.customer_id
	JOIN invoiceline il ON i.invoice_id = il.invoice_id
	JOIN track t ON il.track_id = t.track_id
	JOIN genre g ON t.genre_id = g.genre_id
	GROUP BY c.country, g.genre_id
) as genre_stats 
WHERE rank_purchase = 1;

-- Question 11
SELECT * FROM customer;
SELECT * FROM invoice;
WITH top_cus_into AS
(
	SELECT CONCAT(c.first_name, ' ', c.last_name) as customer_name, c.country as country_name , sum(i.total) as total_spent,
    DENSE_RANK() OVER(PARTITION BY c.country ORDER BY c.country, SUM(i.total) desc) as customer_rank
	FROM customer c
	JOIN invoice i ON c.customer_id = i.customer_id
	GROUP BY country_name, customer_name
	ORDER BY country_name, total_spent desc
)
SELECT *
FROM top_cus_into
WHERE customer_rank = 1;
