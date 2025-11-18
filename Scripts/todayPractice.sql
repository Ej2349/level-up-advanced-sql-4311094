SELECT LastName, Count(*) AS LastNameCount
FROM CarforAll
GROUP BY LastName
HAVING Count(*) > 1;