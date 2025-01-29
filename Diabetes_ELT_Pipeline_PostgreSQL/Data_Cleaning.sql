
-- Update records where column 'gender' does not have the expected values.
UPDATE patientDetails_rw
SET gender = 'Unknown'
WHERE gender NOT IN ('Male', 'Female') OR gender is null;

-- Update records for column 'outcome' with the expected values
UPDATE patientDetails_rw
SET outcome = 0
WHERE outcome IN ('0', 'False', 'false', 'o')
returning *;

UPDATE patientDetails_rw
SET outcome = 1
WHERE outcome IN ('1', 'True', 'true', 'Yes')
returning *;

-- Implement similar update script for 'readmission' column.

-- Update invalid date column values as null
UPDATE patientDetails_rw
SET visitDate = NULL
WHERE patientID in (SELECT patientID FROM patientDetails_rw
where check_date(visitDate) = False)
returning *;

-- Update date format to expected format(i.e. 'DD-MM-YYYY')
UPDATE patientDetails_rw
SET VisitDate = TO_CHAR(VisitDate::date, 'DD-MM-YYYY')
WHERE VisitDate ::TEXT !~ '^\d{2}-\d{2}-\d{4}$'
returning *;

-- Update query to make the negative bmi values as positive
UPDATE patientDetails_rw
SET bmi = abs(cast(bmi as double precision))
WHERE cast(bmi as double precision) < 0
returning *;

-- Update query to make the negative glucoselevel values as positive
UPDATE patientDetails_rw
SET glucoselevel = abs(cast(glucoselevel as INTEGER))
WHERE cast(glucoselevel as INTEGER) < 0
returning *;