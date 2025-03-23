--Netflix Project
DROP TABLE  IF EXISTS netflix
CREATE TABLE netflix
(
show_id VARCHAR(6),
type VARCHAR(10),
title VARCHAR(150),
director VARCHAR(208),
casts VARCHAR(1000),
country VARCHAR(150),
date_added VARCHAR(50),
release_year INT,
rating VARCHAR(10),
duration VARCHAR(15),
listed_in VARCHAR(100),
description VARCHAR(250)
);

SELECT * FROM netflix;

SELECT COUNT(*) Total_content
FROM netflix;

SELECT DISTINCT type 
FROM netflix;

-- 1. Count the no. of Movies vs TV Shows

SELECT type,
COUNT(*) as total_count
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows

SELECT type, rating
FROM
(SELECT type, rating,
COUNT(*),
RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
FROM netflix
GROUP BY type, rating) as t1
WHERE ranking = 1;

--3. Select all movies released in a specific year

SELECT *
FROM netflix
--(SELECT * FROM netflix WHERE release_year = 2020) as t2
WHERE type = 'Movie' AND release_year = 2020

--4. Top 5 countries with the most content on Netflix

SELECT 
TRIM(UNNEST(STRING_TO_ARRAY(Country,','))) as new_country,
COUNT(show_id) as total_content
FROM netflix
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;

--5. Identify the longest movie

SELECT type, title,
SPLIT_PART(duration,' ',1) :: INT as time
FROM netflix
WHERE type='Movie' AND duration IS NOT NULL
ORDER BY time DESC
LIMIT 1;

--6. Find the content added in the last 5 years

ALTER TABLE netflix
ALTER COLUMN date_added TYPE DATE
USING TO_DATE(date_added,'Month DD, YYYY');

SELECT * FROM netflix
WHERE date_added >= CURRENT_DATE - INTERVAL '5 YEARS';

--7. Find all the TV Shows/ movies by director 'Rajiv Chilaka'

SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

--8. Select all TV Shows with more that 5 seasons

SELECT *
FROM Netflix
WHERE type='TV Show' AND SPLIT_PART(duration,' ',1)::INT > 5;

--9. Count the no. of items in each genre

SELECT
TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) AS genre,
COUNT(show_id) AS total_content
FROM netflix
GROUP BY genre;

--10. Find each year and average no. of content release in India on netflix.
--    return top 5 year with highest avg content release

SELECT EXTRACT(YEAR FROM date_added) AS years,
COUNT(show_id) AS total_content,
ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country LIKE '%India%')::numeric * 100,2) avg_content
FROM netflix
WHERE country LIKE '%India%'
GROUP BY years;

--11. List all the movies that are documentaries

SELECT genre, title
FROM
(SELECT *,TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) AS genre
FROM netflix)
WHERE genre = 'Documentaries';

--12. Find all the content without a director

SELECT title, director
FROM netflix
WHERE director IS NULL;

--13. Find how many movies actor Salman Khan appeared in last 10 years

SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%' AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

--14. Find 10 actors who have appeared in the highest no. of movies produced in India

SELECT 
TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) AS actors,
COUNT(show_id) AS no_of_movies
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY actors
ORDER BY no_of_movies DESC
LIMIT 10;

--15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field.
--    Label content containing these words as 'Bad' and all other content as 'Good'. Count how many items fall into each category

WITH new_table
AS(
SELECT title, description,
CASE
	WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad_Content'
	ELSE 'Good_Content'
END AS category
FROM netflix)
SELECT category, COUNT(*) AS total_content
FROM new_table
GROUP BY category;