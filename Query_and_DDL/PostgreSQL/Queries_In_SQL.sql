--1.Retrieve names of officers who investigated more than the average number of FIRs handled by officers. 
SELECT o.name 
FROM officer o
JOIN investigated_by i ON o.badge_no = i.badge_no
GROUP BY o.badge_no, o.name
HAVING COUNT(i.fir_no) > (
    SELECT AVG(fir_count)
    FROM (
        SELECT COUNT(fir_no) AS fir_count
        FROM investigated_by
        GROUP BY badge_no
    ) t
);


--2. Find all crimes that occurred in a specific location within a given time frame.
SELECT * 
FROM crime
WHERE state = 'MP'
AND date_and_time BETWEEN '2025-01-15 10:00:00' 
AND '2025-03-22 17:45:00';


--3. Find high-crime areas by calculating the number of crimes reported in each location.
SELECT city, state, COUNT(fir_no) total_crime
FROM crime
GROUP BY city, state
ORDER BY total_crime 
DESC LIMIT 3;


--4. Analyze crime trends by finding the most common types of crimes.
SELECT type_of_crime, COUNT(fir_no) number_of_cases
FROM crime
GROUP BY type_of_crime
ORDER BY number_of_cases DESC;



--5. Identify the criminal involved in this crime and the officer who arrested them for given fir_no
SELECT DISTINCT cr.name criminal_name, o.name officer_name
FROM crime c
NATURAL JOIN commits co
JOIN criminal cr ON cr.criminal_id = co.criminal_id
NATURAL JOIN investigated_by ib
JOIN officer o ON ib.badge_no = o.badge_no
WHERE c.fir_no = 'CR001';


--6. Given city name find all crime details and victim details that affect from this crime
SELECT fir_no, type_of_crime, description, police_station, v.victim_no, name
FROM crime 
NATURAL JOIN affects a
LEFT JOIN victim v
ON a.victim_no = v.victim_no
WHERE city = 'Surat';

--7. List all criminals who have committed more than one type of crime
SELECT c.criminal_id, cr.name
FROM commits c
NATURAL JOIN crime cri
JOIN criminal cr ON c.criminal_id = cr.criminal_id
GROUP BY c.criminal_id, cr.name
HAVING COUNT(DISTINCT cri.type_of_crime) > 1;


--8. List all prisoners who are due for release in the 10 months along with their release dates. 
SELECT prisoner_id, prisoner_name, release_date
FROM prisoners
WHERE release_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '10 month'
ORDER BY release_date;

--9. Arrange criminals by the number of crimes they have committed.
SELECT name, criminal_id, count 
FROM 
	(SELECT criminal_id, COUNT(*) AS count
	FROM commits
	GROUP BY criminal_id) r
NATURAL JOIN criminal
ORDER BY count DESC;

--10. Find the list of prisoners whose sentence duration is above the average sentence duration.
SELECT prisoner_id, prisoner_name, sentence_duration
FROM prisoners
WHERE sentence_duration > (
    SELECT AVG(sentence_duration) as avg
    FROM prisoners
);


--11. Find the number of officers per department.
SELECT department, COUNT(*) officers_count
FROM officer
GROUP BY department
ORDER BY officers_count DESC;


--12. Find the number of crimes reported per month.
SELECT DATE_TRUNC('month', date_and_time) AS month, COUNT(*) count  --In PostgreSQL, DATE_TRUNC truncates a timestamp or interval to a specified precision (e.g., year, month, day, hour). 
FROM crime
GROUP BY month
ORDER BY month;

--13. Find the total number of victims affected in each crime type
SELECT c.type_of_crime, COUNT(a.victim_no)  total
FROM affects a
JOIN crime c ON a.fir_no = c.fir_no
GROUP BY c.type_of_crime
ORDER BY total DESC;

--14. Find the total number of evidences collected per fir_no.
SELECT fir_no, COUNT(*) evidence_count
FROM evidence
GROUP BY fir_no
ORDER BY evidence_count
DESC;

--15. Find the criminal who committed the maximum number of crimes
SELECT criminal_id, name, COUNT(fir_no) total
FROM criminal
NATURAL JOIN commits
GROUP BY criminal_id, name
ORDER BY total
DESC LIMIT 1;

--16. Find officers who are investigating the most number of crimes.
SELECT badge_no, name, COUNT(fir_no) total 
FROM officer
NATURAL JOIN investigated_by
GROUP BY badge_no, name
ORDER BY total 
DESC LIMIT 1;

--17. Count number of crimes in each police station.
SELECT police_station, COUNT(*) total
FROM crime
GROUP BY police_station
ORDER BY total DESC;

--18. Find which year had the highest number of crimes reported.
SELECT EXTRACT(YEAR FROM date_and_time) AS year, COUNT(*) total
FROM crime
GROUP BY year
ORDER BY total
DESC LIMIT 1;


--19. Show all prisoners whose name starts with 'A'
SELECT * 
FROM prisoners 
WHERE prisoner_name LIKE 'A%';


--20. Show all prisoners along with their crime type
SELECT prisoner_name, type_of_crime
FROM prisoners 
NATURAL JOIN convicts co
JOIN "case" c ON c.case_id = co.case_id
JOIN crime cr ON c.fir_no = cr.fir_no;

