-- code to create table within database
CREATE TABLE website_logs (
		access_date timestamptz,
		duration numeric,
		network_protocol text,
		ip text,
		bytes numeric,
		accessed_from text,
		age text,
		gender text,
		country text,
		membership text,
		language text,
		sales numeric,
		returned text,
		returned_amount numeric,
		pay_method text
);

-- code to copy CSV file from desktop to database
COPY website_logs
FROM '/Users/alexbruno/Desktop/website_logs.csv'
WITH (FORMAT CSV, HEADER);

SELECT *
FROM website_logs;

-- to find an error:
SELECT length(network_protocol),
	count(*) AS length_count
FROM website_logs
WHERE network_protocol LIKE '%HTTP%'
GROUP BY length(network_protocol);

-- to find an error:
SELECT DISTINCT accessed_from
FROM website_logs;

-- code to correct extra whitespce in network_protocol column
START TRANSACTION;

UPDATE website_logs
SET network_protocol = TRIM(network_protocol);

SELECT network_protocol
FROM website_logs
GROUP BY network_protocol;

COMMIT;

-- code to correct 'SafFri' values to 'Safari'
START TRANSACTION;

UPDATE website_logs
SET accessed_from = 'Safari'
WHERE accessed_from ILIKE '%SafFri%';

COMMIT;

-- code to correct lowercase in language column
START TRANSACTION;

UPDATE website_logs
SET language = initcap(language);

COMMIT;

-- code to standardize NULL and '--' values in age column
START TRANSACTION;

UPDATE website_logs
SET age = 'Unidentified'
WHERE age IS NULL;

UPDATE website_logs
SET age = 'Unidentified'
WHERE age = '--';

SELECT age, count(*)
FROM website_logs
GROUP BY age
ORDER BY age;

COMMIT;

-- code to explore membership and gender relationship to sales
SELECT membership, gender
	count(*) AS total_transactions,
	round(sum(sales), 2) AS total_sales,
	round(avg(sales), 2) AS avg_sales_per_group,
	round((SELECT avg(sales) FROM website_logs WHERE sales != 0), 2) AS overall_avg
FROM website_logs
WHERE sales != 0
GROUP BY membership, gender
ORDER BY total_sales DESC, membership;

-- code to explore purchase patterns by age groups
SELECT 
	CASE
		WHEN age::numeric < 20 THEN 'Below 20'
		WHEN age::numeric BETWEEN 20 and 29 THEN '20 - 29'
		WHEN age::numeric BETWEEN 30 and 39 THEN '30 - 39'
		WHEN age::numeric BETWEEN 40 and 49 THEN '40 - 49'
		WHEN age::numeric BETWEEN 50 and 59 THEN '50 - 59'
		WHEN age::numeric BETWEEN 60 and 69 THEN '60 - 69'
	END AS age_groups,
	count(*) AS total_transactions,
	round(sum(sales), 2) AS total_sales,
	round(avg(sales), 2) AS avg_per_sale
FROM website_logs
WHERE age != 'Unidentified'
GROUP BY age_groups
ORDER BY age_groups;

-- code to explore daily sales and returns activity
SELECT CONCAT('Mar -', date_part('day', access_date)) AS day,
	round(sum(sales), 2) AS total_sales,
	round(sum(returned_amount), 2) AS returned_amount
FROM website_logs
GROUP BY day
ORDER BY day;