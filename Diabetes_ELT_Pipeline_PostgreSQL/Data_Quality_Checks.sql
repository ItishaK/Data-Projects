
-- Basic Preliminary Data Checks
select count(*) from patientDetails_rw as TotalRows_rw;
select count(*) from patientDetails_history as TotalRows_history;
select * from patientDetails_rw limit 5;
select * from patientDetails_history limit 5;

-- Check for NULL values
SELECT
    COUNT(*) AS TotalRecords,
    COUNT(*) - COUNT(patientID) AS Null_PatientID,
    COUNT(*) - COUNT(age) AS Null_Age,
    COUNT(*) - COUNT(gender) AS Null_Gender,
    COUNT(*) - COUNT(bmi) AS Null_BMI,
    COUNT(*) - COUNT(glucoseLevel) AS Null_GlucoseLevel,
    COUNT(*) - COUNT(outcome) AS Null_Outcome,
    COUNT(*) - COUNT(readmission) AS Null_Readmission,
    COUNT(*) - COUNT(visitDate) AS Null_VisitDate
FROM patientDetails_rw;

-- Identify NULL values
SELECT *
FROM patientDetails_rw
WHERE visitDate IS NULL or gender IS NULL;

-- Check for duplicate PatientID values
SELECT patientID, COUNT(*)
FROM patientDetails_rw
GROUP BY patientID
HAVING COUNT(*) > 1;

-- Check for distinct Boolean values i.e. outcome and readmission
Select distinct(outcome)
from patientDetails_rw
where outcome not in (0, 1);

Select distinct(readmission)
from patientDetails_rw
where readmission not in (0, 1);

-- Date validation Function
create function check_date(s varchar) returns boolean
language plpgsql
as $$
begin
  perform s::date;
  return true;
exception when others then
  return false;
end;
$$;

SELECT patientID, visitDate
FROM patientDetails_rw
where check_date(visitDate) = False;

-- Date format validation (DD-MM-YYYY)
SELECT patientid, visitdate
FROM patientDetails_rw
WHERE visitDate IS NOT NULL
  AND visitDate::TEXT !~ '^\d{2}-\d{2}-\d{4}$';

-- Count distinct Age groups
SELECT age, COUNT(*)
FROM patientDetails_rw
GROUP BY age;

-- Validate distinct Age groups
Select distinct(age)
from patientDetails_rw
where age not in ('20-30', '30-40', '40-50', '50-60', '60-70');

-- Total Patient Count by Gender
SELECT
    gender,
    COUNT(*) AS TotalPatients
FROM patientDetails_rw
GROUP BY gender
ORDER BY gender;

-- Check for outliers
-- Out-of-range BMI values (Between 10 and 50)
SELECT patientID, bmi
FROM patientDetails_rw
WHERE cast(bmi as double precision) < 10 
OR cast(bmi as double precision) > 50;

-- Check for invalid BMI values (Negative Values)
SELECT patientID, bmi
FROM patientDetails_rw
WHERE cast(bmi as double precision) < 0;

-- Check for invalid GlucoseLevel values (Negative Values)
SELECT patientID, glucoseLevel
FROM patientDetails_rw
WHERE cast(glucoseLevel as integer) < 0;

-- Check for logical inconsistencies in Outcome and Readmission
SELECT patientID, bmi, glucoseLevel, outcome, readmission
FROM patientDetails_rw
WHERE outcome = 0 AND readmission = 1;