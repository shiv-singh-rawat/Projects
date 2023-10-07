-- EASY
-- Q1: Who is the senior most employee based on job title?

SELECT * FROM EMPLOYEE
ORDER BY LEVELS DESC
LIMIT 1;

-- Q2: Which country have most invoices?

select count(*) as c, billing_country from invoice
group by billing_country
order by c Desc; 

-- Q3: What are top 3 values of total invoices?

select * from invoice
order by total desc
limit 3;

-- Q4 : Which city  has the best cost? we would like to throw a promostional musical fastival  in the city
-- we made the most money, Write a query that return one city that has the highest sum of invoices 
-- total. Return both the city name &  sum of all invoices totals.

select sum(total) as sum, billing_city from invoice
group by billing_city
order by sum Desc;
 
 -- Q4 : who is the best costomer? The costomer who spend the most money will be declare the best costomer.write a query that return 
-- the person who has spend the most money..

select c.customer_id ,c.first_name, c.last_name, SUM(i.total) as total from customer as c 
join invoice as i
on c.customer_id = i.customer_id
group by c.customer_id,c.first_name, c.last_name,total
order by total Desc
limit 1;

-- MODERATE
-- Q1 - Write a query to return the email, firstname ,lastname, genre and all Rock music listeners.
-- Return your list order alphabatically by email starting with A.
select c.email,c.first_name,c.last_name from customer as c
join invoice as i on c.customer_id = i.customer_id
join invoice_line on i.invoice_id = invoice_line.invoice_id
where track_id in(
		select track_id from track 
        join genre on track.genre_id = genre.genre_id
        where genre.name like "Rock"
)
order by email;

-- Q2 - Lets invited the artist who have written the most rock music in our dataset.
-- Write a query that written the artist name and total  track count of the top 10 rock
 -- bands..
SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id, artist.name
ORDER BY number_of_songs DESC;

-- Q3 - Return the track names that have a song legnth longer than the avg song length. Return the Name and Milliseconds for each track.
-- order by the song lenght with the logest song listed first?
SELECT name,milliseconds FROM track
where milliseconds>(
		select avg(milliseconds) 
        from track )
order by milliseconds desc;

-- ADVANCE
-- Q! - Find how much  amount spend by each customers on artist? Write a query to return customer name, 
-- artist name and total spend? 


with best_selling_artist as (
		select artist.artist_id as artist_id ,artist.name As artist_name,
        sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
        from invoice_line 
        join track  on track.track_id = invoice_line.invoice_id
        join album on album.album_id = track.album_id
        join artist on artist.artist_id = album.artist_id
        group by artist_id,artist_name 
        order by 3 desc
        limit 1
        
) 
select c.customer_id,c.first_name,c.last_name,best_selling_artist.artist_name,
sum(il.unit_price*il.quantity) as amount_spend
from invoice as i 

join customer as c on c.customer_id = i.customer_id
join invoice_line as il on il.invoice_id = i.invoice_id
join track on track.track_id = il.track_id
join album on album.album_id = track.album_id
join best_selling_artist on best_selling_artist.artist_id = album.artist_id
group by c.customer_id,c.first_name,c.last_name,best_selling_artist.artist_name
order by c.customer_id,c.first_name,c.last_name,best_selling_artist.artist_name,amount_spend Desc;


-- Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre 
-- as the genre with the highest amount of purchases. Write a query that returns each country along with the 
-- top Genre. For countries where the maximum number of purchases is shared return all Genres. 

WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;

-- Q3: Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount.
WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;



