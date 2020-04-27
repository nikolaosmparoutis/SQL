https://sqlzoo.net/wiki/Guest_House_Assessment_Hard
-- Question 11.
-- Methods i applied from top to down:
-- Used pivoting with case statements
-- self joins for row search of same value
-- nested self join for join with other table
-- creation of date ranges
-- comparison of date ranges using exclusion from the upper and lower bounds.
-- rows distinction using group by at the end (DISTINCT CASE did not produce the distinction)
-- (the online compiler does not allow to do DDL with temporary table).

SELECT 
(CASE WHEN t1.last_name = t2.last_name AND t1.first_name != t2.first_name THEN t1.last_name END) last_name,
(CASE WHEN t1.last_name = t2.last_name AND t1.first_name != t2.first_name THEN t1.first_name END) first_name_pers1,
(CASE WHEN t1.last_name = t2.last_name AND t1.first_name != t2.first_name THEN t2.first_name END) first_name_pers2
FROM 
(
 SELECT
 DISTINCT(t_same_ln.id),
 t_same_ln.last_name, 
 t_same_ln.first_name,
 b.booking_date,
 b.nights
 FROM
 (SELECT 
  g.id, 
  g.first_name, 
  g.last_name
  FROM guest as g JOIN guest gu 
  ON (g.last_name = gu.last_name) 
  WHERE g.id != gu.id
  ORDER BY g.last_name
  )t_same_ln
  JOIN booking b 
 ON(t_same_ln.id = b.guest_id)
)t1 
JOIN 
(
 SELECT
 DISTINCT(t_same_ln.id),
 t_same_ln.last_name, 
 t_same_ln.first_name,
 b.booking_date,
 b.nights
 FROM
 (SELECT 
  g.id, 
  g.first_name, 
  g.last_name
  FROM guest as g JOIN guest gu 
  ON (g.last_name = gu.last_name) 
  WHERE g.id != gu.id
  ORDER BY g.last_name
  )t_same_ln
  JOIN booking b 
  ON(t_same_ln.id = b.guest_id)
 )t2

ON (t1.last_name = t2.last_name)
AND t1.booking_date <=
 DATE_ADD(t2.booking_date, INTERVAL (t2.nights-1) DAY) 
AND DATE_ADD(t1.booking_date, INTERVAL (t1.nights-1) DAY) >=
 t2.booking_date
WHERE t1.id != t2.id
AND t1.first_name != t2.first_name

GROUP BY t1.last_name  
ORDER BY t1.last_name

####################
--Question 12
-- Hacks used to solve this:
-- 1. To find the floor we cannot use substring_index because there is not delmiter. 
--   room_no is an id so is an integer so if i find the number of digits in id 
--   (ex 101) = 3 digits and if i create the 100 (using zero padding with RPAD)
--   and i do the division 101/100 = 1.01 i created the delimiter, then using 
--   substring_index i get the first digit (floor number).
-- 2. To pivot i used  CASE statements although without sum we get dublicates in 
--   checkout dates and is not the the requested format so i did a trick which is like 
--   doing WITH ROLL UP topically for each group of checkouts. 
--   Used the SUM taking into advantage the existence of numbers and NULLS 
--   (delete every SUM and check it)

SELECT checkout,
SUM((CASE WHEN floor = 1 THEN crooms END)) 1st_floor,
SUM((CASE WHEN floor = 2 THEN crooms END)) 2nd_floor,
SUM((CASE WHEN floor = 3 THEN crooms END)) 3rd_floor
FROM
(
SELECT DATE_ADD(b.booking_date, INTERVAL b.nights DAY) checkout, 
SUBSTRING_INDEX(b.room_no / RPAD('1',LENGTH(b.room_no),'0'),'.',1) floor,
COUNT(b.room_no) crooms
FROM booking b 
GROUP BY floor, checkout
HAVING checkout >= "2016-11-14"
ORDER BY checkout
)t
GROUP BY checkout

####################
