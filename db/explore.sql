-- Run these in SAP HANA Database Explorer, inside your HDI container.
-- HANA stores table names in capital letters: hr.Employees becomes HR_EMPLOYEES.

-- 1. All employees
SELECT FIRSTNAME, LASTNAME, DEPARTMENT, USERID FROM HR_EMPLOYEES;

-- 2. All leave requests with the employee's name
SELECT E.FIRSTNAME, L.STARTDATE, L.ENDDATE, L.DAYS, L.STATUS
  FROM HR_LEAVEREQUESTS L
  JOIN HR_EMPLOYEES E ON E.ID = L.EMPLOYEE_ID
 ORDER BY L.STARTDATE;

-- 3. Leave days per status
SELECT STATUS, COUNT(*) AS REQUESTS, SUM(DAYS) AS TOTAL_DAYS
  FROM HR_LEAVEREQUESTS
 GROUP BY STATUS;

-- 4. The view CAP made for the service
SELECT * FROM HRSERVICE_LEAVEREQUESTS;
