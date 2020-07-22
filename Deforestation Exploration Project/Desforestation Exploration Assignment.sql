--Creating VIEW for forestation
CREATE VIEW forestation AS
SELECT
fa.country_name AS country_name,
r.region AS region,
fa.year AS year,
fa.forest_area_sqkm AS forest_area_sqkm,
la.total_area_sq_mi * 2.59 AS total_area_sqkm, ROUND((fa.forest_area_sqkm/(la.total_area_sq_mi*2.59)*100)::numeric, 2) AS
percent_forest
FROM forest_area fa
JOIN land_area la
ON fa.country_code = la.country_code AND fa.year = la.year
JOIN regions r
ON r.country_code = la.country_code AND r.country_code = fa.country_code GROUP BY 1,2,3,4,5
ORDER BY 2,3,1,6;
-- Part 1
-- Question a. What was the total forest area (in sq km) of the world in 1990? Please keep in mind that you can use the country record denoted as “World" in the region table.
SELECT year,
forest_area_sqkm FROM forestation
WHERE year = '1990' AND country_name = 'World';
-- Question b. What was the total forest area (in sq km) of the world in 2016? Please keep in mind that you can use the country record in the table is denoted as “World.” SELECT year,
forest_area_sqkm FROM forestation
WHERE year = '2016' AND country_name = 'World';
--Question c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?
WITH total_2016 AS (SELECT country_name,
year,
forest_area_sqkm FROM forestation
WHERE year = '2016' AND country_name = 'World'),
total_1990 AS (SELECT country_name, year,
forest_area_sqkm FROM forestation
WHERE year = '1990' AND country_name = 'World')
SELECT (a.forest_area_sqkm - b.forest_area_sqkm) AS world_forest_area_change
FROM total_1990 AS a
INNER JOIN total_2016 AS b
ON a.country_name = b.country_name;
--Question d. What was the percent change in forest area of the world between 1990 and 2016?
WITH total_2016 AS (SELECT country_name,
year,
forest_area_sqkm FROM forestation
WHERE year = '2016' AND country_name = 'World'), total_1990 AS (SELECT country_name,
year,
forest_area_sqkm FROM forestation
WHERE year = '1990' AND country_name = 'World') SELECT (a.forest_area_sqkm - b.forest_area_sqkm)/a.forest_area_sqkm*100 AS
world_forest_area_percent_change FROM total_1990 AS a
INNER JOIN total_2016 AS b
ON a.country_name = b.country_name;
--Question e. If you compare the amount of forest area lost between 1990 and 2016, to which country's total area in 2016 is it closest to?

SELECT country_name,
(total_area_sq_mi * 2.59) total_area_sqkm
FROM forestation
WHERE (total_area_sq_mi * 2.59) <= (WITH total_2016 AS (SELECT country_name,
 --Creating regional_outlook table
 country_name = 'World'),
country_name = 'World') world_forest_area_change
'2016'
ORDER BY 2 DESC
LIMIT 1;
--PART 2
CREATE TABLE regional_outlook AS SELECT region,
year,
forest_area_sqkm FROM forestation
WHERE year = '2016' AND
total_1990 AS (SELECT country_name, year,
forest_area_sqkm FROM forestation
WHERE year = '1990' AND SELECT (a.forest_area_sqkm - b.forest_area_sqkm )AS
FROM total_1990 AS a
INNER JOIN total_2016 AS b
ON a.country_name = b.country_name) AND year =
year,
ROUND((SUM(forest_area_sqkm)*100/SUM(total_area_sqkm))::numeric, 2) AS
percent_forestation FROM forestation GROUP BY 1, 2;
-- Question a. What was the percent forest of the entire world in 2016? Which region had the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places? SELECT region,
percent_forestation FROM regional_outlook
WHERE year = '2016' ORDER BY 2 DESC;
--Question b. What was the percent forest of the entire world in 1990? Which region had the HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places? SELECT region,
percent_forestation FROM regional_outlook
WHERE year = '1990' ORDER BY 2 DESC;
--Question c. Based on the table you created, which regions of the world DECREASED in forest area from 1990 to 2016?
WITH total_1990 AS (SELECT region,
percent_forestation FROM regional_outlook WHERE year = '1990'),
total_2016 AS (SELECT region, percent_forestation
FROM regional_outlook

WHERE year = '2016')
SELECT a.region, CASE WHEN (b.percent_forestation - a.percent_forestation) < 0 THEN 'Decrease' ELSE 'Increased' END AS trend
FROM total_1990 AS a
INNER JOIN total_2016 AS b
ON a.region = b.region
WHERE a.region != 'World' AND b.region != 'World'
GROUP BY 1,2;
--Part 3
--Question a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? What was the difference in forest area for each?
WITH old AS (SELECT country_name,
region,
year, forest_area_sqkm
FROM forestation WHERE year = '1990'),
new AS (SELECT country_name, year,
region,
forest_area_sqkm FROM forestation
WHERE year = '2016')
SELECT a.country_name AS "Country Name", a.region,
(a.forest_area_sqkm - b.forest_area_sqkm) AS "Difference in Total Forest Area (sq. km)"
FROM new AS a
INNER JOIN old AS b
ON a.country_name = b.country_name
WHERE (a.forest_area_sqkm - b.forest_area_sqkm) IS NOT NULL
AND a.country_name != 'World' ORDER BY 3
LIMIT 5;
--Question b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? What was the percent change to 2 decimal places for each?
WITH old AS (SELECT country_name,
year,
region, forest_area_sqkm
FROM forestation WHERE year = '1990'),
new AS (SELECT country_name, year,
region,
forest_area_sqkm FROM forestation
WHERE year = '2016')
SELECT a.country_name AS "Country Name", a.region AS "Region",
ROUND(((a.forest_area_sqkm - b.forest_area_sqkm)/b.forest_area_sqkm*100)::numeric, 2) AS "Change in Total Forest Area (%)"

FROM new AS a
INNER JOIN old AS b
ON a.country_name = b.country_name
WHERE ((a.forest_area_sqkm - b.forest_area_sqkm)/b.forest_area_sqkm*100) IS NOT NULL
AND a.country_name != 'World' ORDER BY 3
LIMIT 5;
--Question c. If countries were grouped by percent forestation in quartiles, which group had the most countries in it in 2016?
WITH t1 AS (SELECT country_name,
percent_forest,
CASE
WHEN percent_forest >= 0 AND percent_forest <= 25 THEN 1 WHEN percent_forest > 25 AND percent_forest <= 50 THEN 2 WHEN percent_forest > 50 AND percent_forest <= 75 THEN 3 ELSE 4
END AS quartile FROM forestation
WHERE year = '2016'
AND percent_forest IS NOT NULL
AND country_name != 'World')
SELECT quartile, COUNT(quartile)
FROM t1
GROUP BY 1
ORDER BY 1;
--Question d. List all forest > 75%) in 2016. SELECT country_name,
region,
percent_forest FROM forestation
count
of the countries that were in the 4th quartile (percent
WHERE year = '2016'
AND country_name != 'World' AND percent_forest IS NOT NULL AND percent_forest >= 75
ORDER BY 3;
--Question e. How many countries had a percent forestation higher than the United States in 2016?
SELECT COUNT(*)
FROM forestation
WHERE percent_forest > (SELECT percent_forest FROM forestation
WHERE year = '2016'
AND country_name = 'United States') AND year = '2016';
