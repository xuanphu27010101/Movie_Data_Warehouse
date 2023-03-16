INSERT INTO DimDate (date_id, fulldate, year, quarter, month, day, is_weekend, day_of_week)
SELECT
    date_id,
    MIN(payment_date) as fulldate,
    EXTRACT(year FROM MIN(payment_date)) as year,
    EXTRACT(quarter FROM MIN(payment_date)) as quarter,
    EXTRACT(month FROM MIN(payment_date)) as month,
    EXTRACT(day FROM MIN(payment_date)) as day,
    case when EXTRACT(dow FROM MIN(payment_date)) IN (0, 6) THEN true ELSE false END as is_weekend,
    extract(dow from MIN(payment_date)) as day_of_week	
FROM (
    SELECT DISTINCT
        TO_CHAR(DATE_TRUNC('day', payment_date)::DATE, 'yyyyMMDD')::integer as date_id,
        payment_date
    FROM payment
) t
GROUP BY date_id;


INSERT INTO DimCustomer (first_name, last_name, email, address, address2, district, city,
						 postal_code, country, phone, start_date, end_date)
SELECT 
	c.first_name,
	c.last_name,
	c.email,
	a.address,
	a.address2,
	a.district,
	ci.city,
	a.postal_code, 
	co.country,
	a.phone,
	date(now()),
	date(now())
FROM customer c, address a, city ci, country co
WHERE c.address_id = a.address_id 
	AND a.city_id = ci.city_id
	AND ci.country_id = co.country_id;
	
INSERT INTO DimFilm (title, description, release_year, language, length, rating, special_features,
					fulltext, start_date, end_date)
SELECT 
	f.title,
	f.description,
	f.release_year,
	l.name,
	f.length,
	f.rating,
	f.special_features,
	f.fulltext,
	date(now()),
	date(now())
FROM film f, language l
WHERE f.language_id = l.language_id;

INSERT INTO FactSale (date_id, customer_id, film_id, amount)
SELECT 
	TO_CHAR(payment_date::DATE, 'yyyyMMDD')::integer,
	p.customer_id,
	i.film_id,
	p.amount
FROM payment p, rental r, inventory i
WHERE p.rental_id = r.rental_id
	AND r.inventory_id = i.inventory_id;

