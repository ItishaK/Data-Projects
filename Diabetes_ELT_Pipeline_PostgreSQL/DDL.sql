
-- Create History Table
CREATE TABLE patientDetails_history (
    patientID VARCHAR(10),
    age VARCHAR(10),
    gender VARCHAR(10),
    bmi VARCHAR(10),
    glucoseLevel VARCHAR(10),
    outcome VARCHAR(10),
    readmission VARCHAR(10),
    visitDate VARCHAR(10)
);

-- Create Raw Table
create table patientDetails_rw
    as select * from patientDetails_history;	
	
-- Create Refined Table
create table patientDetails_ref(
    seqId SERIAL PRIMARY KEY,
    patientID VARCHAR(10),
    age VARCHAR(10),
    gender VARCHAR(10),
    bmi DOUBLE PRECISION,
    glucoseLevel INTEGER,
    outcome INTEGER,
    readmission INTEGER,
    visitDate DATE
);


-- Create Derived Table for Transformations
CREATE TABLE patientDetails_derived AS
SELECT
    seqId,
    PatientID,
    Age,
    Gender,
    (CASE
    WHEN BMI < 18.5 THEN 'Underweight'
    WHEN BMI BETWEEN 18.5 AND 24.9 THEN 'Normal'
    WHEN BMI BETWEEN 25 AND 29.9 THEN 'Overweight'
    WHEN BMI >= 30 THEN 'Obese'
    ELSE 'Unknown'
END) as BMICategory,
    (CASE
        WHEN outcome = 1 THEN 'DIABETIC'
        WHEN outcome = 0 THEN 'NORMAL'
        ELSE 'UNKNOWN'
        END) AS Glucose_cat,
    (CASE
    WHEN Outcome = 1 AND Readmission = 1 THEN 'Critical - Readmitted'
    WHEN Outcome = 1 AND Readmission = 0 THEN 'Critical - Not Readmitted'
    WHEN Outcome = 0 AND Readmission = 1 THEN 'Stable - Readmitted'
    ELSE 'Stable - Not Readmitted'
END) as PatientStatus
FROM patientDetails_ref;