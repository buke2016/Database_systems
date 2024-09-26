-- African cities HackerRank.com
SELECT city
FROM cities
ON country.code = country.code
WHERE country.continent = "Africa"

