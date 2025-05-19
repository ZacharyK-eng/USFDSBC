/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: `student`
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the Facilities charge a fee to Members, but some do not.
Write a SQL query to produce a list of the names of the Facilities that do. */

select *
from Facilities
where membercost > 0;

/* Q2: How many Facilities do not charge a fee to Members? */

select count(*) as free_facilities
from Facilities
where membercost = 0;

/* Q3: Write an SQL query to show a list of Facilities that charge a fee to Members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
Facilities in question. */

select facid, name, membercost, monthlymaintenance
from Facilities
where membercost > 0
  and membercost < (monthlymaintenance * 0.2);

/* Q4: Write an SQL query to retrieve the details of Facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

select *
from Facilities
where facid in (1, 5);

/* Q5: Produce a list of Facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the Facilities
in question. */

select name, monthlymaintenance,
  case
    when monthlymaintenance > 100 then 'expensive'
    else 'cheap'
  end as cost_category
from Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

select firstname, surname
from Members
where joindate = (select max(joindate) from Members);

/* Q7: Produce a list of all Members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

select distinct 
    Facilities.name as court_name,
    concat_ws(' ',Members.firstname,Members.surname) as member_name
from Bookings 
join Facilities on Bookings.facid = Facilities.facid
join Members on Bookings.memid = Members.memid
where Facilities.name like 'Tennis Court %'
order by member_name;

/* Q8: Produce a list of Bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to Members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

select 
    Facilities.name as facility_name,
    concat_ws(' ', Members.firstname, Members.surname) as member_name,
    case
        when Bookings.memid = 0 then Facilities.guestcost * Bookings.slots
        else Facilities.membercost * Bookings.slots
    end as total_cost
from Bookings
join Facilities on Bookings.facid = Facilities.facid
join Members on Bookings.memid = Members.memid
where date(Bookings.starttime) = '2012-09-14'
  and (
    (Bookings.memid = 0 and Facilities.guestcost * Bookings.slots > 30)
    or (Bookings.memid != 0 and Facilities.membercost * Bookings.slots > 30)
  )
order by total_cost desc;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

select 
    subquery.facility_name,
    subquery.member_name,
    subquery.total_cost
from (
    select 
        Facilities.name as facility_name,
        concat_ws(' ', Members.firstname, Members.surname) as member_name,
        case
            when Bookings.memid = 0 then Facilities.guestcost * Bookings.slots
            else Facilities.membercost * Bookings.slots
        end as total_cost,
        date(Bookings.starttime) as booking_date
    from Bookings
    join Facilities on Bookings.facid = Facilities.facid
    join Members on Bookings.memid = Members.memid
) as subquery
where subquery.booking_date = '2012-09-14'
  and (subquery.total_cost > 30)
order by subquery.total_cost desc;

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of Facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and Members! */


SELECT 
    Facilities.name AS facility_name,
    SUM(
        CASE 
            WHEN Bookings.memid = 0 THEN Facilities.guestcost * Bookings.slots
            ELSE Facilities.membercost * Bookings.slots
        END
    ) AS total_revenue
FROM Bookings
JOIN Facilities ON Bookings.facid = Facilities.facid
GROUP BY Facilities.name
HAVING total_revenue < 1000
ORDER BY total_revenue;

/* Q11: Produce a report of Members and who recommended them in alphabetic surname,firstname order */

SELECT 
    m.firstname || ' ' || m.surname AS member_name,
    r.firstname || ' ' || r.surname AS recommended_by
FROM Members m
LEFT JOIN Members r ON m.recommendedby = r.memid
ORDER BY m.surname, m.firstname;

/* Q12: Find the Facilities with their usage by member, but not guests */

SELECT 
    f.name AS facility_name,
    COUNT(*) AS usage_count
FROM Bookings b
JOIN Facilities f ON b.facid = f.facid
WHERE b.memid != 0
GROUP BY f.name
ORDER BY f.name;


/* Q13: Find the Facilities usage by month, but not guests */

SELECT 
    f.name AS facility_name,
    strftime('%Y-%m', b.starttime) AS month,
    COUNT(*) AS usage_count
FROM Bookings b
JOIN Facilities f ON b.facid = f.facid
WHERE b.memid != 0
GROUP BY f.name, month
ORDER BY f.name, month;

